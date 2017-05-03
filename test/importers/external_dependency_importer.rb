require 'csv_party'

class ExternalDependencyImporter < CSVParty
  depends_on :column_dep, :rows_dep, :import_dep, :errors_dep

  column :first, header: 'First'
  column :second, header: 'Second' do |value|
    # ensures errors block gets run at least once
    raise if value.eql?('0')

    result[:column_dep] = column_dep
    value
  end

  rows do
    result[:rows_dep] = rows_dep
  end

  import do
    result[:import_dep] = import_dep
    import_rows!
  end

  errors do
    result[:errors_dep] = errors_dep
  end
end
