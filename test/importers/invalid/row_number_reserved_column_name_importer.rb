require 'csv_party'

class RowNumberReservedColumnNameImporter < CSVParty::Importer
  column :row_number
end
