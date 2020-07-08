require 'pay_processor.rb'
require 'bepaid.rb'

class PayProcessorBepaid < PayProcessor
  def initialize(options = {})
    c = Rails.application.secrets.bepaid
    @bepaid = BePaid::BePaid.new c[:baseURL], c[:id], c[:secret]

  end

  def checkout(sum, options = {})
    raise 'PayProcessorBepaid requires :return_url option' if options[:return_url].blank?
    raise 'Description should not be blank' if options[:description].blank?

    member = options[:member]
    restrict_personal_info = options[:restrict_personal_info]

    visible_fields = ['email']
    visible_fields += ['first_name', 'last_name'] unless restrict_personal_info

    test_mode = Rails.env.production? ? false : true
    return_url = options[:return_url]
    ro_fields = []
    ro_fields += ['email', 'first_name', 'last_name'] unless restrict_personal_info

    checkout_request = {
      checkout: {
        version: '2.1',
        test: test_mode,
        transaction_type: 'payment',
        order: {
          amount: (sum * 100).to_i,
          currency: 'BYN',
          description: options[:description],
        },
        settings: {
          success_url: return_url,
          decline_url: return_url,
          fail_url: return_url,
          cancel_url: return_url,
          notification_url: options[:notification_url],
          auto_return: 20,
          button_next_text: "Вернуться на сайт МВО",
          language: 'ru',
          customer_fields: {
            visible: visible_fields,
            read_only: ro_fields,
          },
        },
        customer: {
          email: (member and !restrict_personal_info) ? member.email : nil,
          last_name: member ? member.last_name : nil,
          first_name: member ? member.given_names : nil,
        }
      },
    }

    res = @bepaid.post_checkout(checkout_request)
    raise "BePaid checkout error: #{res['message']}" if res.include? 'errors' or !res.include? 'checkout'

    c = Checkout.new
    c.amount = sum
    c.member = member
    c.redirect_url = res['checkout']['redirect_url']
    c.status = 'incomplete'
    c.token = res['checkout']['token']
    c.pay_processor = 'bePaid'

    c = nil unless c.save

    c
  end

  def update_checkout_status!(checkout)
    res = @bepaid.get_checkout_status(checkout.token)
    raise 'bePaid request status error' if res.nil? or res['checkout'].nil?

    c = res['checkout']
    checkout.status = c['status']
    checkout.message = c['message']
    checkout.customer = c['customer']
    checkout.uid = c['gateway_response']['payment']['uid']
    checkout.raw_status = c.to_json
    checkout.save
  end
end
