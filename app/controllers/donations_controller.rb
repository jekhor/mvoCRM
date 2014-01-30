# encoding: utf-8

require 'ipay-notification'

class DonationsController < ApplicationController
  before_filter :authenticate_admin!

  # GET /donations
  # GET /donations.json
  def index
    @donations = Donation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @donations }
    end
  end

  # GET /donations/1
  # GET /donations/1.json
  def show
    @donation = Donation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @donation }
    end
  end

  # GET /donations/new
  # GET /donations/new.json
  def new
    @donation = Donation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @donation }
    end
  end

  # GET /donations/1/edit
  def edit
    @donation = Donation.find(params[:id])
  end

  # POST /donations
  # POST /donations.json
  def create
    @donation = Donation.new(params[:donation])

    respond_to do |format|
      if @donation.save
        format.html { redirect_to @donation, notice: 'Donation was successfully created.' }
        format.json { render json: @donation, status: :created, location: @donation }
      else
        format.html { render action: "new" }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /donations/1
  # PUT /donations/1.json
  def update
    @donation = Donation.find(params[:id])

    respond_to do |format|
      if @donation.update_attributes(params[:donation])
        format.html { redirect_to @donation, notice: 'Donation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donations/1
  # DELETE /donations/1.json
  def destroy
    @donation = Donation.find(params[:id])
    @donation.destroy

    respond_to do |format|
      format.html { redirect_to donations_url }
      format.json { head :no_content }
    end
  end

  def import_ipay
    respond_to do |format|
      format.html
    end
  end

  require 'scanf'

  def parse_ipay
    @notification = IPayNotification.new(params[:notification])
    @donations = Array.new

    @notification.records.each { |r|
      donation = Donation.new
      donation.amount = r['transferred']
      donation.donor = r['client_id']
      donation.document_number = @notification.header['doc_num']
      donation.payment_id = r['payment_id']
      donation.datetime = Time.local *(r['payment_date'].scanf("%04d%02d%02d%02d%02d%02d"))

      @donations << donation
    }

    respond_to do |format|
      if params[:auto]

        success = true
        Donation.transaction do
          begin
            @donations.each {|d| d.save!}
          rescue
            success = false
            raise ActiveRecord::Rollback
          end
        end

        if success
          format.json { render json: @donations, status: :created }
        else
          format.json { render json: @donations.map {|d| { errors: d.errors } }, status: :unprocessable_entity }
        end
      else
        format.html { render 'new' }
      end
    end

  end
end
