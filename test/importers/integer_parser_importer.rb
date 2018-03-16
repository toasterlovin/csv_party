require 'csv_party'

class IntegerParserImporter < CSVParty::Importer
  column :integer, as: :integer
  column :negative_integer, as: :integer
  column :whitespace, as: :integer
  column :decimal, as: :integer
  column :negative_decimal, as: :integer
  column :whitespace_only, as: :integer
  column :blank, as: :integer

  rows do |row|
    self.result = row
  end
end
