# encoding: utf-8

class CrmMailer < ActionMailer::Base
#  default from: "crm@bike.org.by"

  class_attribute :crm_options
  self.crm_options = {}

  def crm_options=(value)
    self.crm_options = crm_options.merge(value).freeze if value
    crm_options
  end

  def member_parsed_email(member, src_mail)
    @member = member
    @src_mail = src_mail

    success = member.id.nil? ? "неудачно" : "успешно"
    mail(to: Rails.configuration.crm_mailer_options[:admin_email], subject: "Обработана анкета (#{member.full_name}): #{success}")
  end

  def payment_parsed_email(payment, text)
    @payment = payment
    @src_mail = text
    success = payment.id.nil? ? "неудачно" : "успешно"

    mail(to: Rails.configuration.crm_mailer_options[:admin_email], subject: "Обработан платёж (#{payment.number}): #{success}")
  end

  def notify_about_registration
    @member = params[:member]

    success = @member.id.nil? ? "неудачно" : "успешно"
    mail(to: Rails.configuration.crm_mailer_options[:admin_email],
         subject: "Обработана анкета (#{@member.given_names} #{@member.last_name}): #{success}")
  end

  def greet_new_member
    member = params[:member]

    notify_member(member, "МВО: Добро пожаловать!")
  end

  def thank_for_payment(payment)
    return if payment.member.nil? or payment.member.email.blank?
    @payment = payment

    notify_member(payment.member, "Ваш членский взнос в МВО получен")
  end

  def remind_about_payment(member)
    @last_payment = Payment.where(:member_id => member.id).order("date DESC").first

    notify_member(member, "МВО: напоминание об уплате членского взноса")
  end

  def admin_message
    @message = params[:message]
    mail(to: mailer_options[:admin_email], subject: params[:subject])
  end

  def test_email(text)
    @text = text
#    mail(to: mailer_options[:admin_email]).deliver_now
    mail(to: 'jekhor@gmail.com')
  end

  private

  def notify_member(member, subj)
    return if member.email.blank?
    @member = member

    if mailer_options[:deliver_to_users]
      @to = "#{member.full_name} <#{member.email}>"
    else
      @to = mailer_options[:admin_email]
    end

    mail(to: @to, cc: nil, subject: subj)
  end

  def mailer_options
    Rails.configuration.crm_mailer_options
  end

end
