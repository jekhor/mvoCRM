# encoding: utf-8

class PagesController < ApplicationController
  def home
    @title = 'Home'
    @member = current_member if member_signed_in?
  end

  def help
    @title = 'Help'
  end
end
