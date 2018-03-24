require 'csv_party'

class AbortedImportImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    abort_import! 'Import was aborted' if row.action == 'Abort'
  end

  import do
    result[:before] = 'Before importing rows'
    import_rows!
    result[:after] = 'After importing rows'
  end
end
