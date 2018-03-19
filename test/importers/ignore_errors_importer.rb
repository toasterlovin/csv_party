require 'csv_party'

class IgnoreErrorsImporter < CSVParty::Importer
  column :value

  rows do |row|
    raise TestCaseError if row.value == 'raise'
    self.result = row
  end

  errors :ignore
end
