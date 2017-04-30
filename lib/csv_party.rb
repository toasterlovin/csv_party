require 'csv'
require 'bigdecimal'
require 'ostruct'

class CSVParty
  attr_accessor :columns, :row_importer, :error_processor

  def initialize(csv_path, options = {})
    @columns = self.class.columns
    @row_importer = self.class.row_importer
    @error_processor = self.class.error_processor

    options[:headers] = true
    dependencies = options.delete(:dependencies)
    @headers = CSV.new(File.open(csv_path)).shift
    @csv = CSV.new(File.open(csv_path), options)

    setup_dependencies(dependencies)
    raise_unless_named_parsers_are_valid
    raise_unless_csv_has_all_headers
  end

  def import!
    import_rows!
  end

  def import_rows!
    loop do
      begin
        row = @csv.shift
        break unless row
        import_row!(row)
      rescue StandardError => error
        process_error(error, @csv.lineno + 1)
        next
      end
    end
  end

  def self.column(column, options, &block)
    raise_if_duplicate_column(column)
    raise_if_missing_header(column, options)

    options = {
      blanks_as_nil: (options[:as] == :raw ? false : true),
      as: :string
    }.merge(options)

    parser = if block_given?
               block
             else
               "#{options[:as]}_parser".to_sym
             end

    columns[column] = {
      header: options[:header],
      parser: parser,
      blanks_as_nil: options[:blanks_as_nil]
    }
  end

  def self.import(&block)
    @row_importer = block
  end

  def self.error(&block)
    @error_processor = block
  end

  def self.columns
    @columns ||= {}
  end

  def self.row_importer
    @row_importer ||= nil
  end

  def self.error_processor
    @error_processor ||= nil
  end

  def self.raise_if_duplicate_column(name)
    return unless columns.has_key?(name)

    raise DuplicateColumnError, "A column named :#{name} has already been \
              defined, choose a different name"
  end
  private_class_method :raise_if_duplicate_column

  def self.raise_if_missing_header(name, options)
    return if options.has_key?(:header)

    raise MissingHeaderError, "A header must be specified for #{name}"
  end
  private_class_method :raise_if_missing_header

  private

  def import_row!(row)
    parsed_row = parse_row(row)
    instance_exec(parsed_row, &row_importer)
  end

  def parse_row(row)
    unparsed_row = OpenStruct.new
    columns.each do |column, options|
      header = options[:header]
      unparsed_row[column] = row[header]
    end

    parsed_row = OpenStruct.new
    columns.each do |column, options|
      value = row[options[:header]]
      parsed_row[column] = parse_column(
        value,
        options[:parser],
        options[:blanks_as_nil]
      )
    end

    parsed_row[:unparsed] = unparsed_row
    parsed_row[:csv_string] = row.to_csv

    return parsed_row
  end

  def parse_column(value, parser, blanks_as_nil)
    if blanks_as_nil && is_blank?(value)
      nil
    elsif parser.is_a? Symbol
      send(parser, value)
    else
      instance_exec(value, &parser)
    end
  end

  def process_error(error, line_number)
    instance_exec(error, line_number, &error_processor)
  end

  def is_blank?(value)
    value.nil? || value.strip.empty?
  end

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
    cleaned_value = value.to_s.strip.gsub(/[^0-9.]/, '')
    BigDecimal.new(cleaned_value)
  end

  def named_parsers
    (private_methods + methods).grep(/_parser$/)
  end

  def columns_with_named_parsers
    columns.select { |_name, options| options[:parser].is_a? Symbol }
  end

  # This error has to be raised at runtime because, when the class body
  # is being executed, the parser methods won't be available unless
  # they are defined above the column definitions in the class body
  def raise_unless_named_parsers_are_valid
    columns_with_named_parsers.each do |name, options|
      parser = options[:parser]
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

  def setup_dependencies(dependencies)
    return unless dependencies

    dependencies.each do |dependency, value|
      self.class.class_eval { attr_accessor dependency }
      send("#{dependency}=", value)
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
