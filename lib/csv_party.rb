require 'csv'
require 'bigdecimal'
require 'csv_party/errors'
require 'csv_party/parsers'
require 'csv_party/dsl'
require 'csv_party/initialization'
require 'csv_party/importing'
require 'csv_party/data'
require 'csv_party/configuration'
require 'csv_party/runner'

module CSVParty
  class Importer
    extend CSVParty::DSL
    include CSVParty::Parsers
    include CSVParty::Initialization
    include CSVParty::Importing
    include CSVParty::Data
  end
end
