require 'csv_party'

class AbortedRowsImporter < CSVParty::Importer
  column :first, header: 'First'
  column :second, header: 'Second'

  rows do |row|
    abort_row 'This row was aborted.' if row.first == 'Aborted'
    result[:imported] = row.first
  end

  errors do |error, _line_number|
    result[:aborted] = error
  end
end
