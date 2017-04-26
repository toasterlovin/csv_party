require 'csv'
require 'bigdecimal'
require 'ostruct'

class CSVParty
  def initialize(csv_path)
    @headers = CSV.new(File.open(csv_path)).shift
    @csv = CSV.new(File.open(csv_path), headers: true)

    raise_unless_named_parsers_are_valid
    raise_unless_csv_has_all_headers
  end

  def import!
    loop do
      begin
        row = @csv.shift
        break unless row
        import_row(row)
      rescue CSV::MalformedCSVError => error
        process_error(error, @csv.lineno + 1)
        next
      end
    end
  end

  def parse_row(row)
    unparsed_row = OpenStruct.new
    parsed_row = OpenStruct.new

    columns.each do |name, options|
      header = options[:header]
      unparsed_value = row[header]
      parser = options[:parser]

      unparsed_row[name] = unparsed_value
      parsed_row[name] = instance_exec(unparsed_value, &parser)
    end

    parsed_row['unparsed'] = unparsed_row
    parsed_row['csv_string'] = row.to_csv

    return parsed_row
  end

  def import_row(row)
    parsed_row = parse_row(row)
    instance_exec(parsed_row, &importer)
  end

  def process_error(error, line_number)
    instance_exec(error, line_number, &error_handler)
  end

  def self.column(name, options, &block)
    raise_if_duplicate_column(name)
    raise_if_missing_header(name, options)

    if block_given?
      columns[name] = { header: options[:header], parser: block }
    else
      parser_method = if options.has_key?(:as)
                        "#{options[:as]}_parser".to_sym
                      else
                        :string_parser
                      end
      columns[name] = {
        header: options[:header],
        parser: proc { |value| send(parser_method, value) },
        parser_method: parser_method
      }
    end
  end

  def self.columns
    @columns ||= {}
  end

  def columns
    self.class.columns
  end

  def self.import(&block)
    @importer = block
  end

  def self.importer
    @importer
  end

  def importer
    self.class.importer
  end

  def self.error(&block)
    @error = block
  end

  def self.error_handler
    @error
  end

  def error_handler
    self.class.error_handler
  end

  def self.raise_if_duplicate_column(name)
    return unless columns.has_key?(name)

    raise DuplicateColumnError, "A column named :#{name} has already been \
            defined, choose a different name"
  end

  def self.raise_if_missing_header(name, options)
    return if options.has_key?(:header)

    raise MissingHeaderError, "A header must be specified for #{name}"
  end

  private

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
    return nil if value.nil? || value.strip.empty?
    value.to_i
  end

  def decimal_parser(value)
    cleaned_value = value.to_s.strip.gsub(/[^0-9.]/, '')
    BigDecimal.new(cleaned_value)
  end

  def named_parsers
    (private_methods + methods).grep(/_parser$/)
  end

  def columns_with_named_parsers
    columns.select { |_name, options| options.has_key?(:parser_method) }
  end

  # This error has to be raised at runtime because, when the class body
  # is being executed, the parser methods won't be available unless
  # they are defined above the column definitions in the class body
  def raise_unless_named_parsers_are_valid
    columns_with_named_parsers.each do |name, options|
      parser = options[:parser_method]
      next if named_parsers.include? parser

      parser = parser.to_s.gsub('_parser', '')
      parsers = named_parsers
                .map { |p| p.to_s.gsub('_parser', '') }
                .join(', :')
      raise UnknownParserError,
            "You're trying to use the :#{parser} parser for the :#{name} \
            column, but it doesn't exist. Available parsers are: :#{parsers}."
    end
  end

  def defined_headers
    columns.map { |_name, options| options[:header] }
  end

  def raise_unless_csv_has_all_headers
    missing_columns = defined_headers - @headers
    return if missing_columns.empty?

    columns = missing_columns.join("', '")
    raise MissingColumnError,
          "CSV file is missing column(s) with header(s) '#{columns}'. \
          File has these headers: #{@headers.join(', ')}."
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
