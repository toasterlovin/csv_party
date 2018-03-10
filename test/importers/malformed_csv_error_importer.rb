require 'csv_party'

class MalformedCSVErrorImporter < CSVParty::Importer
  column :first, header: 'First', as: :string
  column :second, header: 'Second', as: :integer

  rows do |row|
  end

  errors do |error, line_number|
    self.result = [error, line_number]
  end
end
