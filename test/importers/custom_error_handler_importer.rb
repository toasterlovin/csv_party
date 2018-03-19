require 'csv_party'

class CustomErrorHandlerImporter < CSVParty::Importer
  column :value

  rows do |row|
    raise TestCaseError if row.value == 'raise'

    result[:success] = row
  end

  errors do |error, line_number, csv_string|
    result[:error] = error
    result[:line_number] = line_number
    result[:csv_string] = csv_string
  end
end
