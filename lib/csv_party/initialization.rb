module CSVParty
  module Initialization
    def initialize(options = {})
      self.config = self.class.config
      raise_unless_all_options_are_recognized!(options)
      self.csv = DataPreparer.new(options).prepare
      assign_dependencies_if_present(options)
    end

    private

    attr_accessor :config, :csv

    def raise_unless_all_options_are_recognized!(options)
      unrecognized_options = options.keys.reject do |option|
        valid_options.include? option
      end
      return if unrecognized_options.empty?

      raise UnrecognizedOptionsError.new(unrecognized_options,
                                         DATA_OPTIONS,
                                         CSV_OPTIONS,
                                         config.dependencies)
    end

    def assign_dependencies_if_present(options)
      return unless config.dependencies.any?

      config.dependencies.each do |dependency|
        if options.has_key? dependency
          send("#{dependency}=", options.delete(dependency))
        end
      end
    end

    def valid_options
      DATA_OPTIONS + CSV_OPTIONS + config.dependencies
    end
  end
end
