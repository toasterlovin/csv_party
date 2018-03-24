require 'csv_party'

class AbortMessageReservedColumnNameImporter < CSVParty::Importer
  column :abort_message
end
