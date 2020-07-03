# encoding: utf-8

require 'csv'

class MembersController < ApplicationController
#  before_action :set_member, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
#  before_action :authenticate_admin!, :except => :count

  helper_method :sort_column, :sort_direction

  # GET /members
  # GET /members.json
  def index
    @title = "Members"
    @fullwith_page = true

    authorize! :index, Member

    if params[:per_page] == 'all'
      Member.per_page = 100000
    else
      Member.per_page = params[:per_page] || 30
    end

    case sort_column
    when 'payments'
      @members = Member.search(params[:search]).accessible_by(current_ability).includes(:payments).all.sort_by {|m| m.payments.size * (sort_direction == 'asc' ? 1 : -1)}.paginate(:page => params[:page])
    when 'debtor?'
      @members = Member.search(params[:search]).accessible_by(current_ability).includes(:payments).all.sort_by {|m| (m.debtor? ? 1 : 0) * (sort_direction == 'asc' ? 1 : -1)}.paginate(:page => params[:page])
    else
      @members = Member.search(params[:search]).accessible_by(current_ability).page(params[:page]).order(sort_column => sort_direction)
    end

    @skipped_members_count = params[:page].nil? ? 0 : (params[:page].to_i - 1) * Member.per_page

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @members }
      format.csv { render csv: Member.all, :filename => 'members' }
    end
  end

  def count
    @count = Member.where('membership_paused = ? OR membership_paused IS NULL', false).size

    respond_to do |format|
      format.json { render json: {count: @count} }
      format.html { render layout: false }
    end
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @title = "#{@member.last_name} #{@member.given_names}"

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @member }
    end
  end

  # GET /members/new
  # GET /members/new.json
  def new
    @title = "Заявка на вступление"
    @member = Member.new
    @member.phone = "+375"
    @member.card_number = Member.last_card_number + 1
    @member.join_date = Date.today

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @member }
    end
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)
    @member.phone = nil if @member.phone == "+375"

    if @member.site_user.blank?
      @member.site_user = nil
    end

    @member.join_date = Date.today if @member.join_date.blank?
    @member.card_number = Member.last_card_number + 1 if @member.card_number.blank?

    respond_to do |format|
      if @member.save
        CrmMailer.with(member: @member.serializable_hash).notify_about_registration.deliver_later
        CrmMailer.with(member: @member).greet_new_member.deliver_later

        format.html { redirect_to member_pay_path(@member), notice: 'Участник успешно зарегистрирован' }
        format.json { render json: @member, status: :created, location: @member }
      else
        format.html { render action: "new" }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.json
  def update
    params[:member].delete(:site_user) if params[:member][:site_user].blank?

    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy

    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end

  # POST /members/register
  def register
    @member = Member.new(
      last_name: params[:last_name],
      given_names: params[:name],
      email: params[:email],
      phone: params[:phone],
      date_of_birth: params[:date_of_birth],
      photo_url: params[:photo_url],
      subscribe_to_mails: params[:subscribe_to_mails]
    )

    @member.join_date = Date.today
    @member.card_number = Member.last_card_number + 1

    unless @member.save
      logger.warn "Failed to save member: #{@member.errors.inspect}"
    end

    CrmMailer.with(member: @member.serializable_hash).notify_about_registration.deliver_later

    respond_to do |format|
      format.html {render layout: false}
    end
  end

  # POST /members/register_new
  def register_new
    @member = Member.new(
      last_name: params[:last_name],
      given_names: params[:name],
      email: params[:email],
      phone: params[:phone],
      date_of_birth: params[:date_of_birth],
      photo_url: params[:photo_url],
      subscribe_to_mails: params[:subscribe_to_mails]
    )

    @member.join_date = Date.today
    @member.card_number = Member.last_card_number + 1

    respond_to do |format|
      if @member.save
        CrmMailer.with(member: @member.serializable_hash).notify_about_registration.deliver_later

        format.html { redirect_to member_pay_path(@member), notice: 'Участник успешно зарегистрирован' }
        format.json { render json: @member, status: :created, location: @member }
      else
        format.html { render action: "new" }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end

  end

  # GET /members/1/pay
  def pay
    @title = "Оплата взноса"

    if @member.nil?
      @member = Member.find_by email: params[:email]
    end

    respond_to do |format|
      if @member.nil?
        format.html {render action: 'pay_unknown_member'}
      else
        format.html
      end
    end
  end

  def checkout
    sum = BigDecimal(params[:amount])

    payproc = PayProcessor.create

    begin
      checkout = payproc.checkout(sum,
        member: @member,
        return_url: checkouts_return_url,
        notification_url: Rails.env.production? ? checkouts_notify_url : nil,
        description: "Членский взнос в МВО, билет №#{@member.card_number} (#{@member.full_name})",
        email: @member ? @member.email : nil,
      )
    rescue => e
      logger.error "Failed to checkout: #{e.message}"
      checkout = nil
    end

    respond_to do |format|
      if checkout.nil?
        format.html { redirect_to member_pay_url, alert: 'Проблема платёжной системы. Попробуйте позже...'}
      else
        format.html { redirect_to checkout.redirect_url }
      end
    end
  end

  def send_test_email
    @count = Member.where('membership_paused = ? OR membership_paused IS NULL', false).size
    
    text = "Тестовое письмо от МВО CRM\n"
    text += "В МВО сейчас состоит #{@count} человек"

    CrmMailer.test_email(text).deliver_later
  end

  private

  def sort_column
    (%w[payments debtor?] + Member.column_names).include?(params[:sort]) ? params[:sort] : "last_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    permitted = [:address, :email, :phone, :postal_address]

    if can?(:manage, Member) then
      permitted += [:date_of_birth, :given_names, :last_name,
                    :card_number, :site_user, :join_date,
                    :membership_paused, :membership_pause_note,
                    :photo_url]
    else
      permitted += [:date_of_birth, :given_names, :last_name, :photo_url] if action_name == "create"
    end

    params.require(:member).permit permitted
  end

end
