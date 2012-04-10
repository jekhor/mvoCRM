# encoding: utf-8

class PagesController < ApplicationController
  def home
    @title = 'Home'
  end

  def help
    @title = 'Help'
  end
end
