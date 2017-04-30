require 'csv_party'

class BooleanParserImporter < CSVParty
  column :t, header: 't', as: :boolean
  column :T, header: 'T', as: :boolean
  column :true, header: 'true', as: :boolean
  column :TRUE, header: 'TRUE', as: :boolean
  column :one, header: 'one', as: :boolean
  column :true_whitespace, header: 'true whitespace', as: :boolean
  column :f, header: 'f', as: :boolean
  column :F, header: 'F', as: :boolean
  column :false, header: 'false', as: :boolean
  column :FALSE, header: 'FALSE', as: :boolean
  column :zero, header: 'zero', as: :boolean
  column :two, header: 'two', as: :boolean
  column :random, header: 'random', as: :boolean

  rows do |row|
    self.result = row
  end
end
