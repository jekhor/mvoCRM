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
    date = f.object.send(field).nil? ? '' : f.object.send(field)
    opts = {:size => 10, :dateFormat => "yy-mm-dd", :selectOtherMonths => true}
    opts.merge! options
    f.datepicker field, opts
  end
end
