# encoding: utf-8

class IPayNotification
  attr_reader :header, :records

  HEADER_FIELDS = %w(ver sender doc_num doc_date records receiver_code receiver_unp receiver_name receiver_bank receiver_account transfer_date currency total_amount total_fine total_transferred service_num)
  RECORD_FIELDS = %w(record_number service_num personal_account client_name amount fine transferred payment_date payment_id terminal_id notification_number notification_date paid_period client_address reserved1 additional_data identify_type client_id reserved2 reserved3)

  def initialize(text)

    @header = Hash.new
    @records = Array.new

    lines = text.force_encoding("CP1251").encode("UTF-8").split(/\r|\n/)

    lines.each {|line|
      line.chomp!
      if line[0] == '{' and line[-1] == '}'
        line = line[1..-2]

        @header = parse_record(line, HEADER_FIELDS)
        next
      end

      if line[0] == '[' and line[-1] == ']'
        line = line[1..-2]

        record = parse_record(line, RECORD_FIELDS)
        @records << record
        next
      end
    }
  end

  private

  def parse_record(line, keys)
    record = Hash.new

    values = line.split('^')
    keys.each_index {|i|
      record[keys[i]] = values[i]
    }

    record
  end
end
