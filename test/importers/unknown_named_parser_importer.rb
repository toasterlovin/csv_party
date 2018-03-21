require 'csv_party'

class UnknownNamedParserImporter < CSVParty::Importer
  column :custom, as: :mispelled

  rows do
  end

  def custom_parser(value)
    "#{value} plus some text"
  end
end
