module CSVParty
  module Initialization
    def initialize(options = {})
      initialize_import_settings
      initialize_counters_and_statuses
      raise_unless_all_options_are_recognized!(options)
      assign_csv_data_if_present(options)
      assign_csv_options_if_present(options)
      assign_dependencies_if_present(options)
    end

    private

    attr_accessor :config

    def initialize_import_settings
      self.config = self.class.config
    end

    def initialize_counters_and_statuses
      @_rows_have_been_imported = false
      @_current_row_number = 1
      @skipped_rows = []
      @aborted_rows = []
      @error_rows = []
      @aborted = false
    end

    def assign_dependencies_if_present(options)
      return unless config.dependencies.any?

      config.dependencies.each do |dependency|
        if options.has_key? dependency
          send("#{dependency}=", options.delete(dependency))
        end
      end
    end

    def raise_unless_all_options_are_recognized!(options)
      unrecognized_options = options.keys.reject do |option|
        valid_options.include? option
      end
      return if unrecognized_options.empty?

      raise UnrecognizedOptionsError.new(unrecognized_options,
                                         valid_data_options,
                                         valid_csv_options,
                                         config.dependencies)
    end

    def valid_options
      valid_data_options + valid_csv_options + config.dependencies
    end
  end
end
