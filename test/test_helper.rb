require 'simplecov'
SimpleCov.start

require 'csv_party'
require 'csv_party/testing'
require 'minitest/autorun'
require 'securerandom'

# This class exists only to have a unique error class for the purpose of
# testing error handling. In certain cases, we want to throw an error,
# but asserting that StandardError has been raised will also pass in cases
# where any other error that is a subclass of StandardError. Having a unique
# error class avoids this.
class TestCaseError < StandardError
end
