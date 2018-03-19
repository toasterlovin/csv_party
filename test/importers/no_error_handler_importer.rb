require 'csv_party'

class NoErrorHandlerImporter < CSVParty::Importer
  column :value

  rows do
    raise TestCaseError
  end
end
