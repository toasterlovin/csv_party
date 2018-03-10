require 'csv_party'

class IntegerParserImporter < CSVParty::Importer
  column :integer, header: 'Integer', as: :integer
  column :whitespace, header: 'Whitespace', as: :integer
  column :decimal_as_integer, header: 'Decimal', as: :integer
  column :whitespace_only, header: 'Whitespace Only', as: :integer
  column :blank, header: 'Blank', as: :integer

  rows do |row|
    self.result = row
  end
end
