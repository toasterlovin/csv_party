require 'csv_party'

class NextRowImporter < CSVParty::Importer
  column :action
  column :value

  rows do |row|
    if row.action == 'Next'
      next_row!
    else
      result << row
    end
  end
end
