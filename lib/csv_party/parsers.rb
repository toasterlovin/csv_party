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
      value.to_i
    end

    def decimal_parser(value)
      cleaned_value = value
                      .to_s
                      .strip
                      .gsub(/[^\-0-9.]/, '')
      BigDecimal.new(cleaned_value)
    end
  end
end
