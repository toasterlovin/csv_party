require 'csv_party'

class CustomErrorHandlerImporter < CSVParty::Importer
  column :value

  rows do |row|
    raise TestCaseError if row.value == 'raise'

    self.result[:success] = row
  end

  errors do |error, line_number, csv_string|
    self.result[:error] = error
    self.result[:line_number] = line_number
    self.result[:csv_string] = csv_string
  end
end
