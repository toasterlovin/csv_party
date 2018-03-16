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
      value = value.to_s.strip
      value = convert_from_accounting_notation(value)
      value = value.gsub(/[^\-0-9.]/, '')
      value.to_i
    end

    def decimal_parser(value)
      value = value.to_s.strip
      value = convert_from_accounting_notation(value)
      value = value.gsub(/[^\-0-9.]/, '')
      BigDecimal.new(value)
    end

    private

    def convert_from_accounting_notation(value)
      if value =~ /\A\(.*\)\z/
        value.delete('()').insert(0, '-')
      else
        value
      end
    end
  end
end
