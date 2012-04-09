# encoding: utf-8

require 'csv'

class MembersController < ApplicationController

  before_filter :authenticate_admin!

  # GET /members
  # GET /members.json
  def index
    @title = "Members"
    @members = Member.order("last_name").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @members }
      format.csv { render csv: @members }
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

  # GET /members/new
  # GET /members/new.json
  def new
    @title = "New Member"
    @member = Member.new

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
    if @member.joined.nil?
      @member.join_date = nil
      @member.join_protocol = nil
    end

    if @member.site_user.blank?
      @member.site_user = nil
    end

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
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
end
