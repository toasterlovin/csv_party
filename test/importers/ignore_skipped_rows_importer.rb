require 'csv_party'

class IgnoreSkippedRowsImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    skip_row! if row.first == 'Skipped'
    self.result = row
  end

  skipped_rows :ignore
end
