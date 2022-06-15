require 'bigdecimal'

module CSVParty
  module Parsers
    def parse_raw(value)
      value
    end

    def parse_string(value)
      value.to_s.strip
    end

    def parse_boolean(value)
      value = value.to_s.strip.downcase

      if %w[1 t true].include? value
        true
      elsif %w[0 f false].include? value
        false
      else
        nil
      end
    end

    def parse_integer(value)
      prepare_numeric_value(value).to_i
    end

    def parse_decimal(value)
      BigDecimal(prepare_numeric_value(value))
    end

    def parse_date(value, format = nil)
      if format.nil?
        Date.parse(value)
      else
        Date.strptime(value, format)
      end
    rescue ArgumentError
      nil
    end

    def parse_time(value, format = nil)
      if format.nil?
        DateTime.parse(value).to_time
      else
        DateTime.strptime(value, format).to_time
      end
    rescue ArgumentError
      nil
    end

    private

    def prepare_numeric_value(value)
      value = value.to_s.strip
      value = convert_from_accounting_notation(value)
      strip_non_numeric_characters(value)
    end

    def convert_from_accounting_notation(value)
      if value =~ /\A\(.*\)\z/
        value.delete('()').insert(0, '-')
      else
        value
      end
    end

    def strip_non_numeric_characters(value)
      value.gsub(/[^\-0-9.]/, '')
    end
  end
end
