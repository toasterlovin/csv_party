module CSVParty
  module Parsers
    def raw_parser(value)
      value
    end

    def string_parser(value)
      value.to_s.strip
    end

    def boolean_parser(value)
      value = value.to_s.strip.downcase

      if %w[1 t true].include? value
        true
      elsif %w[0 f false].include? value
        false
      else
        nil
      end
    end

    def integer_parser(value)
      prepare_numeric_value(value).to_i
    end

    def decimal_parser(value)
      BigDecimal.new(prepare_numeric_value(value))
    end

    def date_parser(value, format = nil)
      begin
        if format.nil?
          Date.parse(value)
        else
          Date.strptime(value, format)
        end
      rescue ArgumentError
        nil
      end
    end

    def time_parser(value, format = nil)
      begin
        if format.nil?
          DateTime.parse(value).to_time
        else
          DateTime.strptime(value, format).to_time
        end
      rescue ArgumentError
        nil
      end
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
