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

      if is_accounting_negative?(value)
        value = value.delete('()').insert(0, '-')
      end

      value.to_i
    end

    def decimal_parser(value)
      value = value.to_s.strip

      if is_accounting_negative?(value)
        value = value.delete('()').insert(0, '-')
      end

      value = value.gsub(/[^\-0-9.]/, '')
      BigDecimal.new(value)
    end

    private

    def is_accounting_negative?(value)
      value =~ /\A\(.*\)\z/
    end
  end
end
