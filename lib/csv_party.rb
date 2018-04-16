require 'csv'
require 'bigdecimal'
require 'csv_party/errors'
require 'csv_party/dsl'
require 'csv_party/initialization'
require 'csv_party/importing'
require 'csv_party/data_preparer'
require 'csv_party/configuration'
require 'csv_party/runner'

module CSVParty
  class Importer
    extend CSVParty::DSL
    include CSVParty::Initialization
    include CSVParty::Importing
  end
end
