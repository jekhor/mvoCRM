# encoding: utf-8

module MembersHelper
  def m_attr_name(attr)
    Member.human_attribute_name(attr)
  end
end
