# TODO

## 1.0
- ~~Finish documenting DSL spec in DSL.md~~
- ~~Split tests out into separate files~~
- Implement and test DSL.md in entirety
  - Columns
    - Names & headers (revised header name behavior)
    - Raw parser (verify behavior)
    - String parser (verify behavior)
    - Integer parser (handle negative values)
    - Decimal parser (handle negative values)
    - Boolean parser (whitelist negative values; return nil for everythign else)
    - Date parser (implement)
    - Time parser (implement)
    - Custom parser blocks (verify that procs can be used)
    - Custom named parsers (verify behavior)
    - Reserved column names (verify behavior)
    - Parsing `nil` and `blank` values (verify behavior)
  - Importing
    - Rows (verify that error is thrown on missing processor)
    - Files (verify behavior)
    - Errors (`:ignore` option + raise if unspecified)
    - Dependencies (MissingDependency error should happen on import, not instantiation)
  - Flow Control
    - Skip row (implement new behavior)
    - Abort row (implement new behavior)
    - Next row (implement new behavior)
    - Abort import (rework API; return `false` on `importer.import!`)
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

### Add mechanism for exporting skipped/aborted rows as CSV files
