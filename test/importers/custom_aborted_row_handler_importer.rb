require 'csv_party'

class CustomAbortedRowHandlerImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    abort_row! 'aborted row' if row.first == 'Aborted'
    result[:not_aborted] = row
  end

  aborted_rows do |row|
    result[:aborted] = row
  end
end
