# encoding: utf-8

class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admins }
    end
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin }
    end
  end

  # GET /admins/new
  # GET /admins/new.json
  def new
    @admin = Admin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin }
    end
  end

  # GET /admins/1/edit
  def edit
  end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to @admin, notice: 'Admin was successfully created.' }
        format.json { render json: @admin, status: :created, location: @admin }
      else
        format.html { render action: "new" }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admins/1
  # PUT /admins/1.json
  def update
    if params[:admin][:password].blank?
      params[:admin].delete(:password)
      params[:admin].delete(:password_confirmation)
    end

    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to @admin, notice: 'Admin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @admin.destroy

    respond_to do |format|
      format.html { redirect_to admins_url }
      format.json { head :no_content }
    end
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    params[:admin].permit(:email, :password, :password_confirmation, :remember_me)
  end
end
