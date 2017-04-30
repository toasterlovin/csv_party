require 'csv_party'

class BlanksAsNilImporter < CSVParty
  column :empty, header: 'Empty', as: :string
  column :blank, header: 'Blank', as: :string
  column :integer, header: 'Integer', as: :integer
  column :decimal, header: 'Decimal', as: :decimal
  column :boolean, header: 'Boolean', as: :boolean
  column :raw_blank, header: 'Raw Blank', as: :raw
  column :custom, header: 'Custom' do
    'Not nil'
  end
  column :opt_out, header: 'Opt Out', blanks_as_nil: false do
    'Not nil'
  end

  rows do |row|
    self.result = row
  end

  errors do |error|
    raise error
  end
end
