require 'csv_party'

class ExternalDependencyImporter < CSVParty
  column :first, header: 'First'
  column :second, header: 'Second' do |value|
    # ensures errors block gets run at least once
    raise if value.eql?('0')

    result[:column] = column
    value
  end

  rows do
    result[:rows] = rows
  end

  errors do
    result[:errors] = errors
  end
end
