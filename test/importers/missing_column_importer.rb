require 'csv_party'

class MissingColumnImporter < CSVParty::Importer
  column :present, header: 'Present'
  column :missing, header: 'Missing'
end
