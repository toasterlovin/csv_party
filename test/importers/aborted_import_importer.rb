require 'csv_party'

class AbortedImportImporter < CSVParty::Importer
  column :first, header: 'First'
  column :second, header: 'Second'

  rows do |row|
    abort_import 'Import was aborted' if row.first == 'Abort'
  end

  import do
    result[:before] = 'Before importing rows'
    import_rows!
    result[:after] = 'After importing rows'
  end
end
