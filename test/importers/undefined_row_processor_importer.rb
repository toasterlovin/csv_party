require 'csv'

class UndefinedRowProcessorImporter < CSVParty::Importer
  column :product
end
