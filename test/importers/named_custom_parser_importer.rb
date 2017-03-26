require 'csv_party'

class NamedCustomParserImporter < CSVParty
  column :custom_1, header: "Custom 1", as: :custom
  column :custom_2, header: "Custom 2", as: :custom

  import do |row|
    $result = row
  end

  def custom_parser(value)
    "#{value} plus added text"
  end
end
