require 'bigdecimal'
require 'csv'
require 'ostruct'
require 'csv_party/configuration'
require 'csv_party/dsl'
require 'csv_party/data_preparer'
require 'csv_party/errors'
require 'csv_party/row'
require 'csv_party/runner'

module CSVParty
  DATA_OPTIONS = [:path, :file, :content].freeze
  CSV_OPTIONS = CSV::DEFAULT_OPTIONS.keys.freeze

  def self.included(base)
    base.extend DSL
  end

  attr_reader :skipped_rows, :aborted_rows, :error_rows
  attr_accessor :aborted, :abort_message

  def initialize(options = {})
    self.config = self.class.config
    raise_unless_all_options_are_recognized!(options)
    self.csv = DataPreparer.new(options).prepare
    assign_dependencies_if_present(options)
  end

  def import!
    @skipped_rows = []
    @aborted_rows = []
    @error_rows = []
    @aborted = false
    self.runner = Runner.new(csv, config, self)
    runner.import!
  end

  def aborted?
    @aborted
  end

  def present_columns
    runner.present_columns
  end

  def missing_columns
    runner.missing_columns
  end

  private

  attr_accessor :runner, :config, :csv

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
