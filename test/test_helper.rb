require 'minitest/autorun'
require 'securerandom'
Dir[File.dirname(__FILE__) + '/importers/*.rb'].each { |file| require file }

class CSVParty::Importer
  # Add an instance level attribute for passing results back to tests
  attr_accessor :result
end
