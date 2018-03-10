DSL Spec
-

# Columns

- Column name & header

    column price: 'Price'

- :raw returns the value from the CSV file, unchanged
- :string strips whitespace and returns the resulting string
- :integer strips whitespace, then calls to_i on the resulting string
- :decimal strips all characters except 0-9 and ., then passes the resulting string to BigDecimal.new
- :boolean strips whitespace, downcases, then returns true if the resulting string is '1', 't', or 'true', otherwise it returns false
- :date strips all whitespace, parses with `Date.strptime`
- :time strips all whitespace, parses with `Time.strptime`
- Parsers can be specified with block or proc
- Throw errors when using reserved column names (`unparsed` & `csv_string`)
- Deal with negative numbers
- `nil` and blank values

# Rows
This is for specifying what happens with each row. It is required.

    rows do |row|
      # `row.column_name` for parsed column values
      # `row.unparsed.column_name` for unparsed column values
      # `row.csv_string` for the raw csv_string
      # `row.line_number` for the line in the CSV file
    end

# Files
This is for defining behavior that should happen before, after, or around
actually importing the rows in the file. It is optional.

    import do
      # do some stuff before importing rows
      import_rows!
      # do some stuff after importing rows
    end

# Errors
This is for gracefully handling errors that may arise in `column`, `rows`,
`import`, and `errors` blocks. It is optional. If no error handler is defined,
errors will simply be raised as they normally would.

    errors :ignore # silently ignore errors

    errors do |error, line_number, csv_string|
      # handle error
    end

# Dependencies
This is for specifying external dependencies that are required while importing
the CSV file.

    depends_on :product_import

    column :product do |value|
      product_import.some_method
    end

    rows do |row|
      product_import.some_method
    end

    # and so on in error handling blocks, etc.

External dependencies are the passed when instantiating the importer:

    MyImporter.new('path/to/csv', product_import: product_import).import!

    MyImporter.new('path/to/csv').import! # raises a MissingDependency error

# Flow Control
Several flow control methods are available in `column`, `rows`, `import`,
and `errors` blocks:

## `skip_row!`
This stops importing the current row and adds it to the `@skipped_rows`
instance variable. It is intended for rows that should normally be skipped,
such as blank rows, etc. Custom handling can be specified:

    rows do |row|
      # we don't need to do anything with this row
      skip_row! 'optional message'
    end

    skipped_rows :ignore # to do nothing

    skipped_rows do |row|
      # handle skipped row
    end

    my_import.skipped_rows # returns array of skipped rows
    my_import.skipped_rows.first.skip_message

## `abort_row!`
This stops importing the current row and adds it to the `@skipped_rows`
instance variable. It is intended for rows that should normally be imported,
but cannot be for some reason. Custom handling can be specified:

    rows do |row|
      # processing cannot continue do to an issue with the data
      abort_row! 'optional message'
    end

    aborted_rows :ignore # to do nothing

    aborted_rows do |row|
      # handle aborted row
    end

    my_import.aborted_rows # returns array of aborted rows
    my_import.aborted_rows.first.abort_message

## `next_row!`
This silently stops importing the current row. It is intended to be used
in instances where processing is done for a given row. There is no way to
specify a handler.

    rows do |row|
      # this row is done being imported
      next_row!
    end

## `abort_import!`
This stops importing the entire file and returns false.

    rows do |row|
      # some unrecoverable error condition is encountered
      abort_import! 'Import could not continue because of reasons'
    end

    if my_importer.import!
      # success
    else
      puts my_importer.abort_message
    end
