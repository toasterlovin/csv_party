require 'ostruct'

module CSVParty
  class Row
    attr_accessor :row_number, :csv_string, :unparsed

    def initialize(csv_row, config, runner)
      @csv_row = csv_row
      @config = config
      @runner = runner
      @attributes = OpenStruct.new
      parse_row!(csv_row)
    end

    private

    def parse_row!(csv_row)
      self.csv_string = csv_row.to_csv
      self.unparsed = extract_unparsed_values(csv_row)

      @config.columns.each do |column, options|
        header = options[:header]
        value = csv_row[header]
        @attributes[column] = parse_value(value, options)
      end
    end

    def extract_unparsed_values(csv_row)
      unparsed_row = OpenStruct.new
      config.columns.each do |column, options|
        header = options[:header]
        unparsed_row[column] = csv_row[header]
      end

      return unparsed_row
    end

    def parse_value(value, options)
      return nil if options[:intercept_blanks] && is_blank?(value)

      parser = options[:parser]

      if parser.is_a?(Symbol)
        parse_with_method(value, options)
      else
        parse_with_block(value, options)
      end
    end

    def parse_with_method(value, options)
      format = options[:format]
      parser = options[:parser]

      if format.nil?
        send(parser, value)
      else
        send(parser, value, format)
      end
    end

    def parse_with_block(value, options)
      parser = options[:parser]

      instance_exec(value, &parser)
    end

    def is_blank?(value)
      value.nil? || value.strip.empty?
    end

    def respond_to_missing?(method, _include_private)
      @attributes.respond_to?(method) || @runner.respond_to?(method, true)
    end

    def method_missing(method, *args)
      if @attributes.respond_to?(method)
        @attributes.send(method, *args)
      elsif @runner.respond_to?(method, true)
        @runner.send(method, *args)
      else
        super
      end
    end
  end
end
