module CSVParty
  module Parsers
    def raw_parser(value)
      value
    end

    def string_parser(value)
      value.to_s.strip
    end

    def boolean_parser(value)
      %w[1 t true].include? value.to_s.strip.downcase
    end

    def integer_parser(value)
      prepare_numeric_value(value).to_i
    end

    def decimal_parser(value)
      BigDecimal.new(prepare_numeric_value(value))
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
