require 'csv_party'

class NamedCustomParserImporter < CSVParty::Importer
  column :custom_1, as: :custom
  column :custom_2, as: :custom

  rows do |row|
    self.result = row
  end

  def custom_parser(value)
    "#{value} plus added text"
  end
end
