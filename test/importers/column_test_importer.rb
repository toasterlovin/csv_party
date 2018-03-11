require 'csv_party'

class ColumnTestImporter < CSVParty::Importer
  column :exact
  column :multi_word_exact
  column :whitespace
  column :lower
  column :multi_word_lower
  column :title
  column :multi_word_title
  column :caps
  column :multi_word_caps
  column :mixed
  column :multi_word_mixed
  column :string_header, header: 'String'
  column :regex_header, header: /regex[\d]/

  rows do |row|
    self.result = row
  end
end
