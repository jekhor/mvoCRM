# encoding: utf-8

module MembersHelper
  def m_attr_name(attr)
    Member.human_attribute_name(attr)
  end

  def per_page_links(items, options={})
    items << 'all' if options[:include_all]
    current_page = request.query_parameters[:page].to_i || 1

    items.each {|item|
      if item == request.query_parameters[:per_page] or item == options[:current]
        concat content_tag 'em', item.to_s, {:class => 'current'}, false
      else
        unless options[:current].nil? or item == 'all'
          page = (options[:current].to_i * (current_page - 1) / item) + 1
        else
          page = 1
        end
        concat link_to item.to_s, request.query_parameters.merge({:per_page => item, :page => page})
      end
    }
    nil
  end
end
