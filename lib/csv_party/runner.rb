module CSVParty
  class Runner
    attr_accessor :csv, :config, :importer

    def initialize(csv, config, importer)
      self.csv = csv
      self.config = config
      self.importer = importer
      @_rows_have_been_imported = false
      @_current_row_number = 1
    end

    def import!
      raise_unless_row_processor_is_defined!
      raise_unless_all_named_parsers_exist!
      raise_unless_all_dependencies_are_present!
      initialize_csv!
      initialize_regex_headers!
      raise_unless_csv_has_all_columns!
      initialize_row_structs!

      if config.file_importer
        instance_exec(&config.file_importer)
        raise_unless_rows_have_been_imported!
      else
        import_rows!
      end

      return true
    rescue AbortedImportError => error
      importer.aborted = true
      importer.abort_message = error.message
      return false
    end

    def present_columns
      @_headers
    end

    def missing_columns
      config.required_columns - present_columns
    end

    private

    def initialize_csv!
      csv.shift
      @_headers = csv.headers
      csv.rewind
    end

    def import_rows!
      loop do
        begin
          row = csv.shift
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

    def import_row!(csv_row)
      @_current_row_number += 1
      parse_row(csv_row)
      instance_exec(@_current_parsed_row, &config.row_importer)
    end

    def parse_row(csv_row)
      @_current_parsed_row = @_parsed_row_struct.new
      @_current_parsed_row[:row_number] = @_current_row_number
      @_current_parsed_row[:csv_string] = csv_row.to_csv
      @_current_parsed_row[:unparsed] = extract_unparsed_values(csv_row)

      config.columns.each do |column, options|
        header = options[:header]
        value = csv_row[header]
        @_current_parsed_row[column] = parse_value(value, options)
      end
    end

    def extract_unparsed_values(csv_row)
      unparsed_row = @_unparsed_row_struct.new
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

    def handle_error(error, line_number, csv_string)
      raise error unless config.error_handler

      if config.error_handler == :ignore
        error_rows << error_struct(error, line_number, csv_string)
      else
        instance_exec(error, line_number, csv_string, &config.error_handler)
      end
    end

    def handle_skipped_row(error)
      return if config.skipped_row_handler == :ignore

      @_current_parsed_row[:skip_message] = error.message

      if config.skipped_row_handler.nil?
        importer.skipped_rows << @_current_parsed_row
      else
        instance_exec(@_current_parsed_row, &config.skipped_row_handler)
      end
    end

    def handle_aborted_row(error)
      return if config.aborted_row_handler == :ignore

      @_current_parsed_row[:abort_message] = error.message

      if config.aborted_row_handler.nil?
        importer.aborted_rows << @_current_parsed_row
      else
        instance_exec(@_current_parsed_row, &config.aborted_row_handler)
      end
    end

    def error_struct(error, line_number, csv_string)
      Struct.new(:error, :line_number, :csv_string)
            .new(error, line_number, csv_string)
    end

    def raise_unless_row_processor_is_defined!
      return if config.row_importer

      raise UndefinedRowProcessorError.new
    end

    def raise_unless_rows_have_been_imported!
      return if @_rows_have_been_imported

      raise UnimportedRowsError.new
    end

    def raise_unless_all_dependencies_are_present!
      config.dependencies.each do |dependency|
        next unless importer.send(dependency).nil?

        raise MissingDependencyError.new(self, dependency)
      end
    end

    # This error has to be raised at runtime because, when the class body
    # is being executed, the parser methods won't be available unless
    # they are defined above the column definitions in the class body
    def raise_unless_all_named_parsers_exist!
      config.columns_with_named_parsers.each do |name, options|
        parser = options[:parser]
        next if named_parsers.include? parser

        raise UnknownParserError.new(name, parser, named_parsers)
      end
    end

    def named_parsers
      (importer.private_methods + importer.methods).grep(/_parser$/)
    end

    def raise_unless_csv_has_all_columns!
      return if missing_columns.empty?

      raise MissingColumnError.new(present_columns, missing_columns)
    end

    def initialize_regex_headers!
      config.columns_with_regex_headers.each do |name, options|
        found_header = @_headers.find do |header|
          options[:header].match(header)
        end
        options[:header] = found_header || name.to_s
      end
    end

    def initialize_row_structs!
      @_parsed_row_struct = Struct.new(*config.columns.keys,
                                       :unparsed,
                                       :csv_string,
                                       :row_number,
                                       :skip_message,
                                       :abort_message)

      @_unparsed_row_struct = Struct.new(*config.columns.keys)
    end

    def respond_to_missing?(method, _include_private)
      importer.respond_to?(method, true)
    end

    def method_missing(method, *args)
      if importer.respond_to?(method, true)
        importer.send(method, *args)
      else
        super
      end
    end
  end
end
