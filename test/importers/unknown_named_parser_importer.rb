require 'csv_party'

class UnknownNamedParserImporter < CSVParty
  column :custom, header: 'Custom', as: :mispelled

  def custom_parser(value)
    "#{value} plus some text"
  end
end
