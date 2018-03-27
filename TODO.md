# TODO

## 1.0
- ~~Finish documenting DSL spec in DSL.md~~
- ~~Split tests out into separate files~~
- ~~Columns~~
  - ~~Names & headers (revised header name behavior)~~
  - ~~Raw parser (verify behavior)~~
  - ~~String parser (verify behavior)~~
  - ~~Integer parser (handle negative values)~~
  - ~~Decimal parser (handle negative values)~~
  - ~~Allow accounting negative notation for integer & decimal~~
  - ~~Boolean parser (whitelist negative values; return nil for everythign else)~~
  - ~~Date parser (implement)~~
  - ~~Time parser (implement)~~
  - ~~Think about what to do with invalid date/time values~~
  - ~~Update error messages to reflect additional parsers~~
  - ~~Custom parser blocks (verify behavior)~~
  - ~~Custom named parsers (verify behavior)~~
  - ~~Reserved column names (verify behavior)~~
  - ~~Parsing `nil` and `blank` values (verify behavior)~~
- ~~Importing~~
  - ~~Rows (verify that error is thrown on missing processor)~~
  - ~~Files (verify behavior + raise error if `import_rows!` is not called)~~
  - ~~Errors (`:ignore` option, raise if unspecified, don't capture parsing errors from CSV library)~~
  - ~~Dependencies (MissingDependency error should happen on import, not instantiation)~~
  - ~~All validations should happen at import time, not instantiation time~~
  - ~~Add row number as attribute on row struct~~
- ~~Flow Control~~
  - ~~Next row (implement new behavior)~~
  - ~~Skip row (implement new behavior)~~
  - ~~Abort row (implement new behavior)~~
  - ~~Abort import (rework API; return `false` on `importer.import!`)~~
- CSV Improvements
  - ~~Accept file path string~~
  - ~~Accept `IO` object~~
  - ~~Accept CSV string~~
  - Raise error if invalid CSV object is assigned
  - Provide access to `defined_headers` and `headers` so missing columns can be reported to users
  - Accept applicable options that `CSV` accepts
  - Test that different encodings work
- Improve test organization
  - Move associated importer classes and CSV files into same file as test.
- Documentation
  - Re-enable class documentation cop
  - Document classes
  - Revamp README.md
  - Flesh out advanced usage in Wiki
    - Testing
    - User specified column names
    - Automatically determining file encoding
    - Low memory usage
    - Downloads of skipped/aborted/errored rows
  - Blog post + video showing best practices in a Rails app

## Future

### Think through what happens when rows that have not been fully parsed are skipped, aborted, have errors, etc.

### Investigate CSV parsing issues
- Make sure parsing issues are well covered by tests
- Resolve line_number off-by-one error when `MalformedCSVError` is encountered

### Add mechanism for exporting skipped/aborted rows as CSV files

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

### Add batch import feature
- Users should be able to accumulate a data structure somehow
- Then a block should be executed every N rows and on the last row

### Allow specifying columns by column number rather than header text

### Allow using multiple columns to generate one variable

    column :total, header: ['Price', 'Quantity'] do |price, quantity|
      BigDecimal.new(price) * BigDecimal.new(quantity)
    end
