require 'csv_party'

class SkippedRowDefaultImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    skip_row! 'skipped row' if row.first == 'Skipped'
    self.result = row
  end
end
