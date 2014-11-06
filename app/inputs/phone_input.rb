class PhoneInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:class] << "form-control"
    @builder.phone_field(attribute_name, input_html_options)
  end
end
