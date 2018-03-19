require 'csv_party'

class MalformedCSVErrorImporter < CSVParty::Importer
  column :first
  column :second, as: :integer

  rows do |row|
  end

  errors :ignore
end
