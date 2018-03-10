# TODO
-

## 1.0
- Finish documenting DSL spec in DSL.md
- Implement and test DSL.md in entirety
- Re-enable class documentation cop
- Document classes

## Future

### Improve `column` DSL method

- Column header doesn't need to be specified

```
column :price # matches 'price', 'Price', 'PRICE', etc.
```

- Column header can be specified with Regex (examples should include case insensitive Regex):

```
column price: /price/
```

### Investigate CSV parsing issues
- Make sure parsing issues are well covered by tests
- Resolve line_number off-by-one error when `MalformedCSVError` is encountered

### Runtime configuration of DSL methods

    my_importer = MyImporter.new
    my_importer.configure do
      column :price, as: :decimal
      rows do |row|
        # import row
      end
    end

### Implement CSV parse error handling
Default behavior is to raise as normal.

    parse_errors :ignore # to do nothing

    parse_errors do |line_number|
      # handle parse error
    end

    my_import.aborted_rows # returns array of parse error rows

### Allow using multiple columns to generate one variable

    column total: ['Price', 'Quantity'] do |price, quantity|
      BigDecimal.new(price) * BigDecimal.new(quantity)
    end
