require 'csv_party'

class MissingColumnImporter < CSVParty::Importer
  column :present
  column :missing

  rows do
  end
end
