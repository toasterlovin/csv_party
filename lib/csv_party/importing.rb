module CSVParty
  module Importing
    attr_reader :skipped_rows, :aborted_rows, :error_rows
    attr_accessor :aborted, :abort_message

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

    attr_accessor :runner
  end
end
