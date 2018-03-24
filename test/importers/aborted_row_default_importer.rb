require 'csv_party'

class AbortedRowDefaultImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    abort_row! 'aborted row' if row.first == 'Aborted'
    self.result = row
  end
end
