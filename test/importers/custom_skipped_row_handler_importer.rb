require 'csv_party'

class CustomSkippedRowHandlerImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    skip_row! 'skipped row' if row.first == 'Skipped'
    result[:not_skipped] = row
  end

  skipped_rows do |row|
    result[:skipped] = row
  end
end
