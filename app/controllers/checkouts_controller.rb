class CheckoutsController < ApplicationController
  before_action :set_checkout, only: :return
  http_basic_authenticate_with name: Rails.application.secrets.bepaid[:id].to_s,
                               password: Rails.application.secrets.bepaid[:secret],
                               only: :notify

  def return
    process_checkout_changes

    respond_to do |format|
      if @checkout.status == 'successful'
        format.html { redirect_to member_path(@checkout.member), flash: {success: "Платёж совершён успешно"} }
      else
        format.html { redirect_to member_path(@checkout.member), alert: "Платёж не удался: #{@checkout.message}" }
      end
    end
  end

  def notify
    @checkout = Checkout.find_by(token: params[:transaction][:additional_data][:vendor][:token])

    process_checkout_changes

    if @checkout.status == 'successful'
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def process_checkout_changes
    handle_checkout_status_change if checkout_status_changed? or @checkout.payment.nil?
  end

  def handle_checkout_status_change
    if @checkout.status == 'successful'
      unless @checkout.payment.blank?
        p = @checkout.payment
        logger.error "Payment for checkout #{@checkout.id} already exists, overwrite"
      else
        p = Payment.new
        @checkout.payment = p
      end
      p.member = @checkout.member
      p.checkout = @checkout
      p.payment_type = 'membership'
      p.amount = @checkout.amount
      p.date = Date.today
      p.fill_dates!
      p.number = @checkout.uid || "checkout_#{@checkout.id}"

      unless p.save
        CrmMailer.with(
          subject: 'Проблема обработки платежа по карте',
          message: "Ошибка сохранения платежа по карте.\n Платёж: " +
            p.pretty_inspect
        ).admin_message.deliver_later
        logger.error p.inspect
        logger.error p.errors.inspect
        raise "Cannot save payment"
      end
      CrmMailer.thank_for_payment(p).deliver_later
    end
  end

  def checkout_status_changed?
    old_status = @checkout.status
    @checkout.update_status!

    old_status != @checkout.status
  end

  def set_checkout
    @checkout = Checkout.find_by(token: params[:token])
  end

  def checkout_params
    params.permit(:token, :status, :uid)
  end
end
