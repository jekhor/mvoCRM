class DatePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    input_html_options[:class] << 'datepicker-input'
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.text_field(attribute_name, merged_input_options)
  end
end
