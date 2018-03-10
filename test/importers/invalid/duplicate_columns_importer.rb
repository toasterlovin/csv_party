class DuplicateColumnsImporter < CSVParty::Importer
  column :product, header: 'Product'
  column :product, header: 'Product'
end
