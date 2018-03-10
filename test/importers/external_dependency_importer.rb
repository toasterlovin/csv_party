require 'csv_party'

class ExternalDependencyImporter < CSVParty::Importer
  depends_on :dependency

  column :first, header: 'First'
  column :second, header: 'Second' do |value|
    # ensures errors block gets run at least once
    raise if value.eql?('0')

    result[:column_dep] = dependency
    value
  end

  rows do
    result[:rows_dep] = dependency
  end

  import do
    result[:import_dep] = dependency
    import_rows!
  end

  errors do
    result[:errors_dep] = dependency
  end
end
