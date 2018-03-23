module CSVParty
  module Initialization
    def initialize(csv_path, options = {})
      initialize_import_settings
      initialize_counters_and_statuses
      initialize_dependencies(options)

      @headers = CSV.new(File.open(csv_path), options).shift
      options[:headers] = true
      @csv = CSV.new(File.open(csv_path), options)
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
      @row_number = 1
      @imported_rows = []
      @skipped_rows = []
      @aborted_rows = []
      @error_rows = []
      @aborted = false
    end

    def initialize_dependencies(options)
      dependencies.each do |dependency|
        if options.has_key? dependency
          send("#{dependency}=", options.delete(dependency))
        end
      end
    end
  end
end
