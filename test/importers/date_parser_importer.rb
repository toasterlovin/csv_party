require 'csv_party'

class DateParserImporter < CSVParty::Importer
  column :date, as: :date
  column :date_with_format, as: :date, format: '%m/%d/%y'

  rows do |row|
    self.result = row
  end

  errors do |error, lineno|
    raise error
  end
end
