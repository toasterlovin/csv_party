require 'csv_party'

class SkippedRowsImporter < CSVParty
  column :first, header: 'First'
  column :second, header: 'Second'

  rows do |row|
    skip_row if row.first == 'Skipped'
    self.result = row.first
  end
end
