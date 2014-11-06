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
    puts PAYMENT_TYPES.inspect
    PAYMENT_TYPES[type]
  end
end
