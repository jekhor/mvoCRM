# encoding: utf-8

require 'csv'
require 'hutkigrosh'

class PaymentsController < ApplicationController
  load_and_authorize_resource
#  before_action :set_payment, only: [:show, :edit, :update, :destroy]
#  before_action :authenticate_admin!

  helper_method :sort_column, :sort_direction

  # GET /payments
  # GET /payments.json
  def index
    authorize! :index, Payment
    @payments = Payment.accessible_by(current_ability).order(sort_column + ' ' + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
      format.csv { render csv: @payments, :filename => 'payments' }
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    store_location_for(:payment, payment_path(@payment))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    @payment = Payment.new
    @payment.member = Member.find(params[:for_member]) unless params[:for_member].nil?
    @payment.member = Member.where("card_number = ?", params[:card_no]).first unless params[:card_no].nil?
    @payment.date = Date.today
    @payment.amount = params[:amount]
    @payment.payment_type = 'membership'


    unless @payment.member.nil?
      last_payment = @payment.member.payments.order(:end_date).last
      if last_payment.nil?
        @payment.start_date = @payment.member.join_date unless @payment.member.join_date.blank?
      else
        @payment.start_date = Date.today.beginning_of_year
      end
    end

    @payment.start_date = Date.today if @payment.start_date.nil?
    @payment.end_date = @payment.start_date.end_of_year

    @members = Member.order('last_name ASC').all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/1/edit
  def edit
    @members = Member.all
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        CrmMailer.thank_for_payment(@payment).deliver_later

        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render json: @payment, status: :created, location: @payment }
      else
        @members = Member.all
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payments/1
  # PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to stored_location_for(:payment) || @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  def hg_notify
    foreign_payment = false
    bill_id = params[:purchaseid]
    c = Rails.application.secrets.hutkigrosh

    p = Payment.new

    hg = HutkiGrosh::HutkiGrosh.new(c[:base_url], c[:user], c[:password])
    begin
      hg.login
      bill = hg.get_bill(bill_id)

      logger.debug bill.to_s

      p.payment_type = c[:erip_ids][bill[:eripId].to_i]

      if p.payment_type.nil?
        raise "Unknown ERIP ID: #{bill[:eripId]}"
      else
        p.number = bill[:billID]
        p.amount = bill[:amt]
        p.user_account = bill[:invId]
        p.date = bill[:payedDt]
        p.full_name = bill[:fullName]
        p.hg_bill = bill.to_json
        p.payment_system = 'erip'
      end

    rescue => e
      logger.info "#{e.class.to_s}: #{e.message}"
      head :unprocessable_entity
      return
    ensure
      hg.logout
    end

    m = nil

    case p.payment_type
    when 'membership'
      m = Member.where(card_number: p.user_account.to_i).first unless p.user_account.blank?
    when 'initial'
      if p.user_account =~ /(([0-9]{2})\.?([0-9]{2})\.?([0-9]{4}))/
        date_of_birth = Time.mktime($4, $3, $2).to_date
        m = Member.where(:date_of_birth => date_of_birth).order('created_at DESC').first unless date_of_birth.nil?
      end
    end

    p.member = m

    unless p.payment_type == 'donation'
      p.fill_dates!
    end

    if p.save
      head :ok
      CrmMailer.thank_for_payment(p).deliver_later
    else
      head :unprocessable_entity
    end

    CrmMailer.payment_parsed_email(p, bill.to_s).deliver_now
  end

  def remind_debtors
    @members = Member.where('membership_paused = ? OR membership_paused IS NULL', false).includes(:payments).all.to_a
    @skipped_members_count = 0 # for list rendering

    @members.delete_if { |m| !m.debtor? }
    @members.each { |m| CrmMailer.with(member: m).remind_about_payment.deliver_later }

    respond_to do |format|
      format.html
    end
  end

  private

  def sort_column
        Payment.column_names.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params[:payment].permit(:date, :amount, :start_date, :end_date, :member_id, :note, :number, :user_account, :payment_type)
  end
end
