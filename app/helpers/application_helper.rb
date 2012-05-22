# encoding: utf-8

module ApplicationHelper
  def title
    base_title = "mvoCRM"

    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def datepicker_su(f, field, options = {})
    date = f.object.send(field).nil? ? '' : f.object.send(field).strftime("%d.%m.%Y")
    opts = {:value => date, :size => 10, :dateFormat => "dd.mm.yy", :selectOtherMonths => true}
    opts.merge(options) if options.is_a?(Hash)
    f.datepicker field, opts
  end
end
