require 'csv_party'

class MalformedCSVErrorImporter < CSVParty
  column :first, header: 'First', as: :string
  column :second, header: 'Second', as: :integer

  import do |row|
  end

  error do |error, line_number|
    self.result = [error, line_number]
  end
end
