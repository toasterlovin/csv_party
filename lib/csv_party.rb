require 'csv'
require 'bigdecimal'
require 'ostruct'
require 'csv_party/errors'
require 'csv_party/parsers'
require 'csv_party/dsl'
require 'csv_party/initialization'
require 'csv_party/importing'

module CSVParty
  class Importer
    include CSVParty::Parsers
    include CSVParty::DSL
    include CSVParty::Initialization
    include CSVParty::Importing
  end
end
