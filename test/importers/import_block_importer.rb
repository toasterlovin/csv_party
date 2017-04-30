require 'csv_party'

class ImportBlockImporter < CSVParty
  column :value, header: 'Value'

  rows do |row|
    result[:rows] << row
  end

  import do
    result[:before] = 'Before'
    import_rows!
    result[:after] = 'After'
  end
end
