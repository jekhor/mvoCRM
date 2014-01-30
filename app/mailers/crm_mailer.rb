# encoding: utf-8

class CrmMailer < ActionMailer::Base
  default from: "crm@bike.org.by"

  def member_parsed_email(member, src_mail)
    @member = member
    @src_mail = src_mail

    success = member.id.nil? ? "неудачно" : "успешно"
    mail(to: 'jekhor@bike.org.by', subject: "Обработана анкета (#{member.full_name}): #{success}").deliver
  end
end
