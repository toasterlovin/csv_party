require 'csv_party'

class CsvRowAsStringImporter < CSVParty
  column :column_1, header: 'Column 1', as: :string
  column :column_2, header: 'Column 2', as: :integer

  rows do |row|
    self.result = row
  end
end
