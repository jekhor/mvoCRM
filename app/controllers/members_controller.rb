# encoding: utf-8

require 'csv'

class MembersController < ApplicationController

  before_filter :authenticate_admin!, :except => :count

  helper_method :sort_column, :sort_direction

  # GET /members
  # GET /members.json
  def index
    @title = "Members"

    if params[:per_page] == 'all'
      Member.per_page = 100000
    else
      Member.per_page = params[:per_page] || 30
    end

    case sort_column
    when 'payments'
      @members = Member.search(params[:search]).all(:include => :payments).sort_by {|m| m.payments.size * (sort_direction == 'asc' ? 1 : -1)}.paginate(:page => params[:page])
    when 'debtor?'
      @members = Member.search(params[:search]).all(:include => :payments).sort_by {|m| (m.debtor? ? 1 : 0) * (sort_direction == 'asc' ? 1 : -1)}.paginate(:page => params[:page])
    else
      @members = Member.search(params[:search]).page(params[:page]).order(sort_column + ' ' + sort_direction)
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
    @member = Member.find(params[:id])
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

        CrmMailer.member_parsed_email(@member, text)
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
    @member = Member.find(params[:id])
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(params[:member])
    @member.phone = nil if @member.phone == "+375"

    if @member.joined.nil?
      @member.join_date = nil
      @member.join_protocol = nil
    end

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
    @member = Member.find(params[:id])
    params[:member].delete(:site_user) if params[:member][:site_user].blank?

    respond_to do |format|
      if @member.update_attributes(params[:member])
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
    @member = Member.find(params[:id])
    @member.destroy

    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end

  # GET /members/import_from_csv
  def import_csv
    @title = "Import members from CSV"
  end

  # POST /members/parse_csv
  def parse_csv
    file = params[:file]
    file.tempfile.set_encoding("utf-8")
    @members = Array.new
    @import_failed = 0

    CSV.parse(file.read, :headers => true) do |row|
      begin
        h = row.to_hash
        m = Member.new(h)
        m.application_exists = true unless h['application_date'].nil? or h['application_date'].blank?

        if m.valid?
          @members << m
        else
          flash.now[:errors] = Array.new if flash.now[:errors].nil?
          flash.now[:errors] << "'#{m.last_name} #{m.given_names}' failed to import: #{m.errors.any? ? m.errors.full_messages.join(', ') : 'unknown reason'}"
          @import_failed += 1
        end
      rescue
        flash.now[:errors] = Array.new if flash.now[:errors].nil?
        flash.now[:errors] << "'#{m.last_name} #{m.given_names}' failed to import: #{m.errors.any? ? m.errors.full_messages.join(', ') : 'unknown reason'}"
        @import_failed += 1
      end
    end

    session[:imported_members] = @members
  end

  # POST /members/import_parsed_csv
  def import_parsed_csv
    imported_members = session[:imported_members]
    selection = params['selected_members']['id']
    successfully = 0
    unless imported_members.nil?
      selection.each do |idx|
        next if idx.blank?
        idx = idx.to_i
        m = imported_members[idx]
        begin
          m.save
          successfully += 1
        rescue
          flash.now[:errors] = Array.new if flash.now[:errors].nil?
          flash.now[:errors] << "'#{m.last_name} #{m.given_names}' failed to import: #{m.errors.any? ? m.errors.full_messages.join(', ') : 'unknown reason'}"
        end
      end
    end
    flash[:notices] = ["#{successfully} members have been imported"]
    session[:imported_members] = nil
    redirect_to members_path
  end

  def accept_selected
    if params[:selected_people][:join_protocol].blank?
      redirect_to members_path, :alert => "You should provide protocol date and number."
      return
    end

    notice = ""

    params[:selected_members][:id].each do |id|
      next if id.blank?
      m = Member.find(id)
      m.update_attributes(params[:selected_people])
      m.joined = true

      m.save
      notice += "#{m.last_name} #{m.given_names} was accepted officially by protocol ##{m.join_protocol} at #{m.join_date}<br/>\n"
    end

    redirect_to members_path, :notice => notice
  end

  def send_test_email
    @count = Member.where('membership_paused = ? OR membership_paused IS NULL', false).size
    
    text = "Тестовое письмо от МВО CRM\n"
    text += "В МВО сейчас состоит #{@count} человек"

    CrmMailer.test_email(text)
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

end
