require 'csv_party'

class BlanksAsNilImporter < CSVParty
  column :empty, header: 'Empty', as: :raw
  column :blank, header: 'Blank', as: :raw
  column :string, header: 'String', as: :string
  column :integer, header: 'Integer', as: :integer
  column :decimal, header: 'Decimal', as: :decimal
  column :boolean, header: 'Boolean', as: :boolean
  column :custom, header: 'Custom' do
    'Not nil'
  end
  column :opt_out, header: 'Opt Out', blanks_as_nil: false do
    'Not nil'
  end

  import do |row|
    self.result = row
  end

  error do |error|
    raise error
  end
end
