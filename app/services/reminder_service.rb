class ReminderService
  def self.remind_for_payment
    members = Member.where('membership_paused = ? OR membership_paused IS NULL', false).includes(:payments).all.to_a
    debtors = members.select { |m| m.debtor? }

    debtors.each do |m|
      next if !m.last_reminded.nil? and m.last_reminded > Date.today - 1.month

#      CrmMailer.with(member: m).remind_about_payment.deliver_now
#      m.update_attribute :last_reminded, Date.today
    end
  end
end
