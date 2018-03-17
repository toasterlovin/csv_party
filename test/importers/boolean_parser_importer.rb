require 'csv_party'

class BooleanParserImporter < CSVParty::Importer
  column :t, as: :boolean
  column :T, as: :boolean
  column :true, as: :boolean
  column :TRUE, as: :boolean
  column :one, as: :boolean
  column :true_whitespace, as: :boolean
  column :f, as: :boolean
  column :F, as: :boolean
  column :false, as: :boolean
  column :FALSE, as: :boolean
  column :zero, as: :boolean
  column :false_whitespace, as: :boolean
  column :random, as: :boolean

  rows do |row|
    self.result = row
  end
end
