require 'csv_party'
require 'minitest/autorun'
require 'securerandom'

module CSVParty
  class Importer
    # Add an instance level attribute for passing results back to tests
    attr_accessor :result
  end
end

# This class exists only to have a unique error class for the purpose of
# testing error handling. In certain cases, we want to throw an error,
# but asserting that StandardError has been raised will also pass in cases
# where any other error that is a subclass of StandardError. Having a unique
# error class avoids this.
class TestCaseError < StandardError
end
