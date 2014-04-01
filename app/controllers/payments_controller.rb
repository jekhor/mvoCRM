# encoding: utf-8

require 'csv'

class PaymentsController < ApplicationController
  before_filter :authenticate_admin!

  helper_method :sort_column, :sort_direction

  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.order(sort_column + ' ' + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
      format.csv { render csv: @payments, :filename => 'payments' }
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    @payment = Payment.find(params[:id])

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


    unless @payment.member.nil?
      last_payment = @payment.member.payments.order(:end_date).last
      if last_payment.nil?
        @payment.start_date = @payment.member.site_user_creation_date unless @payment.member.site_user_creation_date.blank?
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
    @payment = Payment.find(params[:id])
    @members = Member.all
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(params[:payment])

    respond_to do |format|
      if @payment.save
        CrmMailer.thank_for_payment(@payment)

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
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
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
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  def import_hg
    respond_to do |format|
      format.html
    end
  end

  def parse_hg
    @payment = parse_hutkigrosh_mail(params[:mail_text])

    unless @payment.member.nil?
      last_payment = @payment.member.payments.order(:end_date).last
      if last_payment.nil?
        @payment.start_date = @payment.member.site_user_creation_date unless @payment.member.site_user_creation_date.blank?
      else
        @payment.start_date = Date.today.beginning_of_year
      end
    end

    @payment.start_date = @payment.date if @payment.start_date.nil?
    @payment.end_date = @payment.start_date.end_of_year

    @members = Member.order('last_name ASC').all

    respond_to do |format|

      if params[:auto]
        if @payment.save
          CrmMailer.thank_for_payment(@payment)
          format.json { render json: @payment, status: :created }
        else
          format.json {render json: @payment.errors, status: :unprocessable_entity }
        end

        CrmMailer.payment_parsed_email(@payment, params[:mail_text])
      else
        format.html { render 'new' }
      end
    end
  end

  private

  def sort_column
        Payment.column_names.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def parse_hutkigrosh_mail(text)
    payment = Payment.new

    type = nil
    date_of_birth = nil
    member_card_no = nil

    t = text.split(/\n|\r/)
    t.each do |line|
      line.chomp!

      if line =~ /\s*Cумма счета ([0-9. ]+)\s*BYR/
        payment.amount = $1.delete(' ').to_i
        next
      end

      if line =~ /\s*Cчет №\s*(([0-9]{2})\.?([0-9]{2})\.?([0-9]{4}))/
        date_of_birth = Time.mktime($4, $3, $2).to_date
        payment.user_account = $1
        next
      end

      if line =~ /\s*Cчет №\s*([0-9]{6})\s*$/
        member_card_no = $1.to_i
        payment.user_account = $1
        next
      end

      if line =~ /\s*Дата совершения платежа\s+(.*)/
        payment.date = $1.to_date
        next
      end

      if line =~ /\s*Идентификатор операции у расчётного агента\s*([^\s]+)/
        payment.number = $1
        next
      end

      if line =~ /\s*Услуга.*\( ([0-9]+) \)/
        case $1
        when '10051001'
          type = :member
        when '10051002'
          type = :initial
        end
        next
      end

    end

    m = nil

    case type
    when :member
      m = Member.where(:card_number => member_card_no).first unless member_card_no.nil?
    when :initial
      m = Member.where(:date_of_birth => date_of_birth).order('created_at DESC').first unless date_of_birth.nil?
    end

    payment.member = m
    payment.note = text

    payment
  end


end
