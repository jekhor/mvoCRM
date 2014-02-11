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
    mail(to: Rails.configuration.crm_mailer_options[:admin_email], subject: "Обработана анкета (#{member.full_name}): #{success}").deliver
  end

  def payment_parsed_email(payment, text)
    @payment = payment
    @src_mail = text
    success = payment.id.nil? ? "неудачно" : "успешно"

    mail(to: Rails.configuration.crm_mailer_options[:admin_email], subject: "Обработан платёж (#{payment.number}): #{success}").deliver
  end

  def thank_for_payment(payment)
    return if payment.member.nil? or payment.member.email.blank?
    @payment = payment

    notify_member(payment.member, "Ваш членский взнос в МВО получен")
  end

  private

  def notify_member(member, subj)
    @member = member

    if mailer_options[:deliver_to_users]
      to = member.email
      cc = mailer_options[:admin_email]
    else
      to = mailer_options[:admin_email]
      cc = nil
    end

    mail(to: to, cc: cc, subject: subj).deliver
  end

  def mailer_options
    Rails.configuration.crm_mailer_options
  end

end
