require 'csv_party'

class CsvStringReservedColumnNameImporter < CSVParty::Importer
  column :csv_string
end
