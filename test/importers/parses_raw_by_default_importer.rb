class ParsesAsRawByDefaultImporter < CSVParty
  column :whitespace, header: "Whitespace"

  import do |row|
    $result = row
  end
end