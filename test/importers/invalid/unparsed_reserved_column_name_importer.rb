require 'csv_party'

class UnparsedReservedColumnNameImporter < CSVParty::Importer
  column :unparsed
end
