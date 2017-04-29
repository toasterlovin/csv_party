require 'csv_party'

class ExternalDependencyImporter < CSVParty
  column :first, header: 'First'
  column :second, header: 'Second' do |value|
    # ensures error block gets run at least once
    raise if value.eql?('0')

    result[:column] = column
    value
  end

  import do
    result[:import] = import
  end

  error do
    result[:error] = error
  end
end
