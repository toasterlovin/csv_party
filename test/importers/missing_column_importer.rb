require 'csv_party'

class MissingColumnImporter < CSVParty
  column :present, header: "Present"
  column :missing, header: "Missing"
end
