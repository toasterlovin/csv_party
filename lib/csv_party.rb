require 'csv'
require 'bigdecimal'

class CSVParty
  PARSERS = [:boolean, :integer, :decimal, :string, :raw]

  @@columns = {}
  @@importer = nil

  def self.column(name, options, &block)
    header = options[:header]
    raise ArgumentError, "A header must be specified for #{name}" unless header

    if block_given?
      parser = block
    else
      parser_name = options[:as]
      raise ArgumentError, "The parser for #{name} must be one of #{PARSERS.join(", ")}" unless PARSERS.include? parser_name
      parser = Proc.new { |value, context| context.send(:"#{parser_name}_parser", value) }
    end

    @@columns[name] = { header: header, parser: parser }
  end

  def self.import(&block)
    @@importer = block
  end

  def initialize(csv_path)
    @csv_path = csv_path
  end

  def import!
    CSV.foreach(@csv_path, headers: true) do |row|
      parsed_row = parse_row(row)
      import_row(parsed_row)
    end
  end

  def parsed_values
    parsed_values = []
    CSV.foreach(@csv_path, headers: true) do |row|
      parsed_values << parse_row(row)
    end
    parsed_values
  end

  def parse_row(row)
    parsed_row = {}
    @@columns.each do |name, options|
      header = options[:header]
      parser = options[:parser]
      parsed_row[name] = parser.call(row[header], self)
    end
    parsed_row
  end

  def import_row(parsed_row)
    @@importer.call(parsed_row)
  end


  private

  def boolean_parser(value)
    ['1', 't', 'true'].include? value.to_s.strip.downcase
  end

  def integer_parser(value)
    value.to_i
  end

  def decimal_parser(value)
    cleaned_value = value.to_s.gsub(/[^0-9.]/, "")
    BigDecimal.new(cleaned_value)
  end

  def string_parser(value)
    value.to_s.strip
  end

  def raw_parser(value)
    value
  end
end
