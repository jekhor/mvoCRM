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
      @members = Member.search(params[:search]).accessible_by(current_ability).page(params[:page]).order(sort_column + ' ' + sort_direction)
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

  def import_mail
    @title = "Import member from mail"
    respond_to do |format|
      format.html
    end
  end

  def parse_mail
    text = params[:mail_text]

    @member = parse_new_member_mail(text)

    respond_to do |format|
      if params[:auto]
        if @member.save
          format.json { render json: @member, status: :created }
        else
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end

        CrmMailer.member_parsed_email(@member, text).deliver_later
      else
        format.html { render 'new' }
      end
    end
  end

  # GET /members/new
  # GET /members/new.json
  def new
    @title = "New Member"
    @member = Member.new
    @member.phone = "+375"

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

    respond_to do |format|
      if @member.save
        format.html { redirect_to new_payment_for_url(@member), notice: 'Member was successfully created.' }
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

  def parse_new_member_mail(text)
    member = Member.new
    text.gsub!(/(\n|\r)([а-я0-9a-z-])/, ' \2')
    t = text.split(/\n|\r/)

    logger.debug text

    payment_date = nil

    state = nil

    t.each do |line|
      line.chomp!

      if line =~ /Дата оплаты\s*:\s*(.*)$/
        payment_date = Date.strptime($1, '%d.%m.%Y')
        state = nil
        next
      end

      if line =~ /ФИО:\s*(.*)$/
        member.last_name, member.given_names = $1.split(' ', 2)
        state = nil
        next
      end

      if line =~ /Email:\s*(.*)$/
        member.email = $1
        state = nil
        next
      end

      if line =~ /Дата рождения:\s*(.*)$/
        member.date_of_birth = Date.strptime($1, '%d.%m.%Y')
        state = nil
        next
      end

      if line =~ /Адрес регистрации \(прописки\):\s*(.*)$/
        member.address = $1
        state = :registration_address
        next
      end

      if line =~ /Адрес для почтовых отправлений:\s*(.*)$/
        member.postal_address = $1
        state = :postal_address
        next
      end

      if line =~ /Телефон:\s*(.*)$/
        member.phone = $1.gsub(/\s|-/, '')
        state = nil
        next
      end

      if line =~ /Предпочитаемое имя аккаунта на сайте bike.org.by \(никнейм\):\s*(.*)/
        member.site_user = $1
        state = :site_user
        next
      end

      if line.blank?
        state = nil
        next
      end

      case state
      when :postal_address
        member.postal_address += ' ' + line
      when :registration_address
        member.address += ' ' + line
      when :site_user
        member.site_user += ' ' + line
      end
    end

    payments = Payment.where(member_id: nil, date: payment_date, user_account: member.date_of_birth.strftime('%d%m%Y'))
    if payments.size == 1
      member.payments << payments.first
    end

    member
  end

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    permitted = [:address, :email, :phone, :postal_address]

    permitted += [:date_of_birth, :given_names, :last_name,
                  :card_number, :site_user, :site_user_creation_date,
                  :membership_paused,
                  :membership_pause_note] if can? :manage, @member

    params.require(:member).permit permitted
  end

end
