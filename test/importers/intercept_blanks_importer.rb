require 'csv_party'

class InterceptBlanksImporter < CSVParty::Importer
  column :empty, as: :string
  column :blank, as: :string
  column :integer, as: :integer
  column :decimal, as: :decimal
  column :boolean, as: :boolean
  column :date, as: :date
  column :time, as: :time
  column :raw_blank, as: :raw
  column :custom do
    'Not nil'
  end
  column :opt_out, intercept_blanks: false do
    'Not nil'
  end

  rows do |row|
    self.result = row
  end

  errors do |error|
    raise error
  end
end
