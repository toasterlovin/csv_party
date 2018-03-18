require 'csv_party'

class DateParserImporter < CSVParty::Importer
  column :date, as: :date
  column :date_with_format, as: :date, format: '%m/%d/%y'
  column :invalid_date, as: :date
  column :invalid_format, as: :date, format: 'asdf'

  rows do |row|
    self.result = row
  end

  errors do |error|
    raise error
  end
end
