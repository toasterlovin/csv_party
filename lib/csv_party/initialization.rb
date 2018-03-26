module CSVParty
  module Initialization
    def initialize(csv_path, options = {})
      initialize_import_settings
      initialize_counters_and_statuses
      initialize_dependencies(options)

      @_headers = CSV.new(File.open(csv_path), options).shift
      options[:headers] = true
      @_csv = CSV.new(File.open(csv_path), options)
    end

    private

    def initialize_import_settings
      @_columns = self.class.columns
      @_row_importer = self.class.row_importer
      @_file_importer = self.class.file_importer
      @_error_handler = self.class.error_handler
      @_skipped_row_handler = self.class.skipped_row_handler
      @_aborted_row_handler = self.class.aborted_row_handler
      @_dependencies = self.class.dependencies
    end

    def initialize_counters_and_statuses
      @_rows_have_been_imported = false
      @_current_row_number = 1
      @skipped_rows = []
      @aborted_rows = []
      @error_rows = []
      @aborted = false
    end

    def initialize_dependencies(options)
      @_dependencies.each do |dependency|
        if options.has_key? dependency
          send("#{dependency}=", options.delete(dependency))
        end
      end
    end
  end
end
