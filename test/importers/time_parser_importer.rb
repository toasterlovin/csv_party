require 'csv_party'

class TimeParserImporter < CSVParty::Importer
  column :time, as: :time
  column :time_with_timezone, as: :time
  column :time_with_format, as: :time, format: '%m/%d/%y @ %l:%M %p'

  rows do |row|
    self.result = row
  end

  errors do |error|
    raise error
  end
end
