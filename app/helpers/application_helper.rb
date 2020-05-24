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

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, request.query_parameters.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  PAYMENT_TYPES = {'initial' => 'Вступительный взнос',
                   'membership' => 'Членский взнос',
                   'donation' => 'Пожертвование'
  }
  def payment_type_human(type)
    PAYMENT_TYPES[type]
  end

  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-error",
      alert: "alert-danger",
      notice: "alert-success"
    }[flash_type.to_sym] || flash_type.to_s
  end

  def alerts_and_notices
    res = ''
    classes = {notices: 'success', alerts: 'warning', messages: 'info'}
    for name in [:notices, :errors, :messages]
      if flash[name] 
        res += "<div class=\"alert #{classes[name]}\">#{raw flash[name].join('<br/>\n')}</div>"
      end
    end
    res
  end
end
