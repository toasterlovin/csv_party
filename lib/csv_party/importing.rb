module CSVParty
  module Importing
    attr_reader :skipped_rows, :aborted_rows, :error_rows, :abort_message

    def import!
      raise_unless_row_processor_is_defined!
      raise_unless_all_named_parsers_exist!
      raise_unless_all_dependencies_are_present!
      find_regex_headers!
      raise_unless_csv_has_all_columns!

      if @_file_importer
        instance_exec(&@_file_importer)
        raise_unless_rows_have_been_imported!
      else
        import_rows!
      end

      return true
    rescue AbortedImportError => error
      @aborted = true
      @abort_message = error.message
      return false
    end

    def import_rows!
      loop do
        begin
          row = @_csv.shift
          break unless row
          import_row!(row)
        rescue NextRowError
          next
        rescue SkippedRowError => error
          handle_skipped_row(error)
        rescue AbortedRowError => error
          handle_aborted_row(error)
        rescue AbortedImportError
          raise
        rescue CSV::MalformedCSVError
          raise
        rescue StandardError => error
          handle_error(error, @_current_row_number, row.to_csv)
        end
      end

      @_rows_have_been_imported = true
    end

    def aborted?
      @aborted
    end

    def next_row!
      raise NextRowError
    end

    def skip_row!(message = nil)
      raise SkippedRowError, message
    end

    def abort_row!(message = nil)
      raise AbortedRowError, message
    end

    def abort_import!(message)
      raise AbortedImportError, message
    end

    private

    def import_row!(csv_row)
      @_current_row_number += 1
      parse_row(csv_row)
      instance_exec(@_current_parsed_row, &@_row_importer)
    end

    def parse_row(csv_row)
      @_current_parsed_row = create_parsed_row_struct
      @_current_parsed_row[:row_number] = @_current_row_number
      @_current_parsed_row[:csv_string] = csv_row.to_csv
      @_current_parsed_row[:unparsed] = extract_unparsed_values(csv_row)

      @_columns.each do |column, options|
        header = options[:header]
        value = csv_row[header]
        @_current_parsed_row[column] = parse_value(value, options)
      end
    end

    def extract_unparsed_values(csv_row)
      unparsed_row = create_unparsed_row_struct
      @_columns.each do |column, options|
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

    def create_parsed_row_struct
      Struct.new(*@_columns.keys,
                 :unparsed,
                 :csv_string,
                 :row_number,
                 :skip_message,
                 :abort_message).new
    end

    def create_unparsed_row_struct
      Struct.new(*@_columns.keys).new
    end

    def is_blank?(value)
      value.nil? || value.strip.empty?
    end

    def handle_error(error, line_number, csv_string)
      raise error unless @_error_handler

      if @_error_handler == :ignore
        error_rows << error_struct(error, line_number, csv_string)
      else
        instance_exec(error, line_number, csv_string, &@_error_handler)
      end
    end

    def handle_skipped_row(error)
      return if @_skipped_row_handler == :ignore

      @_current_parsed_row[:skip_message] = error.message

      if @_skipped_row_handler.nil?
        skipped_rows << @_current_parsed_row
      else
        instance_exec(@_current_parsed_row, &@_skipped_row_handler)
      end
    end

    def handle_aborted_row(error)
      return if @_aborted_row_handler == :ignore

      @_current_parsed_row[:abort_message] = error.message

      if @_aborted_row_handler.nil?
        aborted_rows << @_current_parsed_row
      else
        instance_exec(@_current_parsed_row, &@_aborted_row_handler)
      end
    end

    def error_struct(error, line_number, csv_string)
      Struct.new(:error, :line_number, :csv_string)
            .new(error, line_number, csv_string)
    end

    def raise_unless_row_processor_is_defined!
      return if @_row_importer

      raise CSVParty::UndefinedRowProcessorError, <<-MSG
Your importer has to define a row processor which specifies what should be done
with each row. It should look something like this:

    rows do |row|
      row.column  # access parsed column values
      row.unparsed.column  # access unparsed column values
    end
      MSG
    end

    def raise_unless_rows_have_been_imported!
      return if @_rows_have_been_imported

      raise CSVParty::UnimportedRowsError, <<-MSG
The rows in your CSV file have not been imported. You should include a call to
import_rows! at the point in your import block where you want them to be
imported. It should should look something like this:

    import do
      # do stuff before importing rows
      import_rows!
      # do stuff after importing rows
    end
      MSG
    end

    def raise_unless_all_dependencies_are_present!
      @_dependencies.each do |dependency|
        next unless send(dependency).nil?

        raise MissingDependencyError, <<-MESSAGE
This importer depends on #{dependency}, but you didn't include it.
You can do that when instantiating your importer:

    #{self.class.name}.new('path/to/csv', #{dependency}: #{dependency})

Or any time before you import:

    importer = #{self.class.name}.new('path/to/csv')
    importer.#{dependency} = #{dependency}
    importer.import!
        MESSAGE
      end
    end

    # This error has to be raised at runtime because, when the class body
    # is being executed, the parser methods won't be available unless
    # they are defined above the column definitions in the class body
    def raise_unless_all_named_parsers_exist!
      columns_with_named_parsers.each do |name, options|
        parser = options[:parser]
        next if named_parsers.include? parser

        parser = parser.to_s.gsub('_parser', '')
        parsers = named_parsers
                  .map { |p| p.to_s.gsub('_parser', '') }
                  .join(', :')
        raise UnknownParserError, <<-MSG
You're trying to use the :#{parser} parser for the :#{name} column, but it
doesn't exist. Available parsers are: :#{parsers}."
        MSG
      end
    end

    def raise_unless_csv_has_all_columns!
      missing_columns = defined_headers - @_headers
      return if missing_columns.empty?

      columns = missing_columns.join("', '")
      raise MissingColumnError, <<-MSG
CSV file is missing column(s) with header(s) '#{columns}'. File has these
headers: #{@_headers.join(', ')}.
      MSG
    end

    def columns_with_regex_headers
      @_columns.select { |_name, options| options[:header].is_a? Regexp }
    end

    def find_regex_headers!
      columns_with_regex_headers.each do |name, options|
        found_header = @_headers.find do |header|
          options[:header].match(header)
        end
        options[:header] = found_header || name.to_s
      end
    end
  end
end
