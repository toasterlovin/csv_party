require 'csv_party'

class NoErrorHandlerImporter < CSVParty::Importer
  column :value

  rows do |row|
    raise TestCaseError
  end
end
