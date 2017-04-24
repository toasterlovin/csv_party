require 'csv_party'

class UnparsedRowValuesImporter < CSVParty
  column :whitespace, header: "String", as: :string

  import do |row|
    $result = row
  end
end
