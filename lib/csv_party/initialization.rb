module CSVParty
  module Initialization
    def initialize(csv_path, options = {})
      initialize_import_settings
      initialize_counters_and_statuses
      initialize_dependencies(options)

      @headers = CSV.new(File.open(csv_path), options).shift
      options[:headers] = true
      @csv = CSV.new(File.open(csv_path), options)

      raise_unless_named_parsers_are_valid
      raise_unless_csv_has_all_headers
    end

    private

    def named_parsers
      (private_methods + methods).grep(/_parser$/)
    end

    def columns_with_named_parsers
      columns.select { |_name, options| options[:parser].is_a? Symbol }
    end

    def defined_headers
      columns.map { |_name, options| options[:header] }
    end

    def initialize_import_settings
      @columns = self.class.columns
      @row_importer = self.class.row_importer
      @importer = self.class.importer
      @error_processor = self.class.error_processor
      @dependencies = self.class.dependencies
    end

    def initialize_counters_and_statuses
      @imported_rows = []
      @skipped_rows = []
      @aborted_rows = []
      @aborted = false
    end

    def initialize_dependencies(options)
      dependencies.each do |dependency|
        if options.has_key? dependency
          send("#{dependency}=", options.delete(dependency))
        else
          raise MissingDependencyError,
            <<-MESSAGE
This importer depends on #{dependency}, but you didn't include it.
Here's how you do that: #{self.class.name}.new('path/to/csv', #{dependency}: #{dependency})
          MESSAGE
        end
      end
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

    def raise_unless_csv_has_all_headers
      find_headers!
      missing_columns = defined_headers - @headers
      return if missing_columns.empty?

      columns = missing_columns.join("', '")
      raise MissingColumnError,
        "CSV file is missing column(s) with header(s) '#{columns}'. \
              File has these headers: #{@headers.join(', ')}."
    end

    def columns_with_regex_headers
      columns.select { |_name, options| options[:header].is_a? Regexp }
    end

    def find_headers!
      columns_with_regex_headers.each do |name, options|
        options[:header] = @headers.find { |header| options[:header] === header } || name.to_s
      end
    end
  end
end
