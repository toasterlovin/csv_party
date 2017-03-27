require 'csv'
require 'bigdecimal'
require 'ostruct'

class CSVParty
  def initialize(csv_path)
    @csv = CSV.new(File.open(csv_path), headers: true)
    raise_unless_named_parsers_are_valid
  end

  def import!
    @csv.each do |row|
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
    if columns.has_key?(name)
      raise DuplicateColumnError, "A column named :#{name} has already been defined, choose a different name"
    end
    unless options.has_key?(:header)
      raise MissingHeaderError, "A header must be specified for #{name}"
    end

    if block_given?
      columns[name] = { header: options[:header], parser: block }
    else
      if options.has_key?(:as)
        parser_method = "#{options[:as]}_parser".to_sym
      else
        parser_method = :string_parser
      end
      columns[name] = {
        header: options[:header],
        parser: Proc.new { |value| send(parser_method, value) },
        parser_method: parser_method
      }
    end
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

  def named_parsers
    (private_methods + methods).grep(/_parser$/)
  end

  def columns_with_named_parsers
    columns.select { |name, options| options.has_key?(:parser_method) }
  end

  # This error has to be raised at runtime because, when the class body
  # is being executed, the parser methods won't be available unless
  # they are defined above the column definitions in the class body
  def raise_unless_named_parsers_are_valid
    columns_with_named_parsers.each do |name, options|
      parser = options[:parser_method]
      unless named_parsers.include? parser
        raise UnknownParserError,
          "You're trying to use the :#{parser.to_s.gsub('_parser', '')} parser for the :#{name} column, but it doesn't exist. Available parsers are: :#{named_parsers.map { |p| p.to_s.gsub('_parser', '') }.join(', :')}."
      end
    end
  end
end

class UnknownParserError < ArgumentError
end

class MissingHeaderError < ArgumentError
end

class DuplicateColumnError < ArgumentError
end

class MissingColumnError < ArgumentError
end
