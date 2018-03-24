require 'csv_party'

class IgnoreAbortedRowsImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    abort_row! if row.first == 'Aborted'
    self.result = row
  end

  aborted_rows :ignore
end
