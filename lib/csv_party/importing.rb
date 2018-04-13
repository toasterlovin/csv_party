module CSVParty
  module Importing
    attr_reader :skipped_rows, :aborted_rows, :error_rows, :abort_message

    def import!
      raise_unless_row_processor_is_defined!
      raise_unless_all_named_parsers_exist!
      raise_unless_all_dependencies_are_present!
      initialize_csv!
      initialize_regex_headers!
      raise_unless_csv_has_all_columns!
      initialize_row_structs!

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

    def present_columns
      @_headers
    end

    def missing_columns
      required_columns - present_columns
    end

    private

    def import_row!(csv_row)
      @_current_row_number += 1
      parse_row(csv_row)
      instance_exec(@_current_parsed_row, &@_row_importer)
    end

    def parse_row(csv_row)
      @_current_parsed_row = @_parsed_row_struct.new
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
      unparsed_row = @_unparsed_row_struct.new
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

      raise UndefinedRowProcessorError.new
    end

    def raise_unless_rows_have_been_imported!
      return if @_rows_have_been_imported

      raise UnimportedRowsError.new
    end

    def raise_unless_all_dependencies_are_present!
      @_dependencies.each do |dependency|
        next unless send(dependency).nil?

        raise MissingDependencyError.new(self, dependency)
      end
    end

    # This error has to be raised at runtime because, when the class body
    # is being executed, the parser methods won't be available unless
    # they are defined above the column definitions in the class body
    def raise_unless_all_named_parsers_exist!
      columns_with_named_parsers.each do |name, options|
        parser = options[:parser]
        next if named_parsers.include? parser

        raise UnknownParserError.new(name, parser, named_parsers)
      end
    end

    def columns_with_named_parsers
      @_columns.select { |_name, options| options[:parser].is_a? Symbol }
    end

    def named_parsers
      (private_methods + methods).grep(/_parser$/)
    end

    def raise_unless_csv_has_all_columns!
      return if missing_columns.empty?

      raise MissingColumnError.new(present_columns, missing_columns)
    end

    def required_columns
      @_columns.map { |_name, options| options[:header] }
    end

    def initialize_regex_headers!
      columns_with_regex_headers.each do |name, options|
        found_header = @_headers.find do |header|
          options[:header].match(header)
        end
        options[:header] = found_header || name.to_s
      end
    end

    def columns_with_regex_headers
      @_columns.select { |_name, options| options[:header].is_a? Regexp }
    end

    def initialize_row_structs!
      @_parsed_row_struct = Struct.new(*@_columns.keys,
                                       :unparsed,
                                       :csv_string,
                                       :row_number,
                                       :skip_message,
                                       :abort_message)

      @_unparsed_row_struct = Struct.new(*@_columns.keys)
    end
  end
end
