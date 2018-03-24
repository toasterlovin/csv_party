require 'csv_party'

class SkipMessageReservedColumnNameImporter < CSVParty::Importer
  column :skip_message
end
