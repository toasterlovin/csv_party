require 'csv_party'

class NamedCustomParserImporter < CSVParty
  column :custom_1, header: 'Custom 1', as: :custom
  column :custom_2, header: 'Custom 2', as: :custom

  rows do |row|
    self.result = row
  end

  def custom_parser(value)
    "#{value} plus added text"
  end
end
