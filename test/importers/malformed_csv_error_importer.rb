require 'csv_party'

class MalformedCSVErrorImporter < CSVParty
  column :first, header: 'First', as: :string
  column :second, header: 'Second', as: :integer

  import do |row|
  end

  error do |error|
    self.result = error
  end
end
