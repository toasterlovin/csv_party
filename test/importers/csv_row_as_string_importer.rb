require 'csv_party'

class CsvRowAsStringImporter < CSVParty
  column :column_1, header: 'Column 1', as: :string
  column :column_2, header: 'Column 2', as: :integer

  import do |row|
    $result = row
  end
end
