require 'csv'
require 'bigdecimal'
require 'ostruct'

class CSVParty
  def initialize(csv_path)
    @csv_path = csv_path
  end

  def import!
    CSV.foreach(@csv_path, headers: true) do |row|
      parsed_row = parse_row(row)
      import_row(parsed_row)
    end
  end

  def parse_row(row)
    parsed_row = OpenStruct.new
    parsed_row[:values] = OpenStruct.new

    columns.each do |name, options|
      header = options[:header]
      parser = options[:parser]
      parsed_row[name] = instance_exec(row[header], &parser)
      parsed_row[:values][name] = row[header]
    end

    return parsed_row
  end

  def import_row(parsed_row)
    importer.call(parsed_row)
  end

  def self.column(name, options, &block)
    header = options[:header]
    raise ArgumentError, "A header must be specified for #{name}" unless header

    if block_given?
      parser = block
    else
      parser_method = options.has_key?(:as) ? "#{options[:as]}_parser" : :raw_parser
      parser = Proc.new { |value| send(parser_method, value) }
    end

    columns[name] = { header: header, parser: parser }
  end

  def self.import(&block)
    @importer = block
  end

  def self.columns
    @columns ||= {}
  end

  def columns
    self.class.columns
  end

  def self.importer
    @importer
  end

  def importer
    self.class.importer
  end

  private


  def raw_parser(value)
    value
  end

  def string_parser(value)
    value.to_s.strip
  end

  def boolean_parser(value)
    ['1', 't', 'true'].include? value.to_s.strip.downcase
  end

  def integer_parser(value)
    value.to_i
  end

  def decimal_parser(value)
    cleaned_value = value.to_s.strip.gsub(/[^0-9.]/, "")
    BigDecimal.new(cleaned_value)
  end
end
