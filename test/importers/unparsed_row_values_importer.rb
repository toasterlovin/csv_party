require 'csv_party'

class UnparsedRowValuesImporter < CSVParty
  column :whitespace, header: 'String', as: :string

  import do |row|
    self.result = row
  end
end
