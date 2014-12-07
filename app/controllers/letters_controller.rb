class LettersController < ApplicationController

  def letter
    l = Letter.new({subject: params[:subject], address: params[:address], text: params[:text]})

    pdf = l.to_pdf

    respond_to do |format|
      format.pdf { send_data pdf, filename: 'letter.pdf' }
    end
  end

  def make_letter
    respond_to do |format|
      format.html
    end
  end
end
