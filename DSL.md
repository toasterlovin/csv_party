# DSL Spec

## Columns

#### Column name & header

    # Default behavior is to do a case insensitive comparison of column name,
    # ignoring whitespace. The following matches `'price'`, `' price '`,
    # `'Price'`, `'PRICE'`, `'PrIcE'`, etc.
    column :price

    # A header name can also be specified as a string
    column :price, header: 'Some random string' # uses

    # Or as a regex
    column :price, header: /price-\d{1,2}/

#### `:raw` parser
Returns the value from the CSV file as a string, unmodified

    column :price, as: :raw
    ' ' #=> ' '
    '1' #=> '1'

#### `:string` parser
Strips whitespace and returns the resulting string. This is the default parser.

    column :price # or
    column :price, as: :string
    ' value ' #=> 'value'

#### `:integer` parser
Strips whitespace, then calls to_i on the resulting string. Values can be positive or negative.

    column :price, as: :integer
    ' 1 ' #=> 1
    ' -1 ' #=> -1

#### `:decimal` parser
Strips all characters except `-`, `0-9` and `.`, then passes the resulting string to `BigDecimal.new`. Values can be positive or negative.

    column :price, as: :decimal
    ' 1 ' #=> 1.0
    ' $1.5 ' #=> 1.5
    ' -$1.5 ' #=> -1.5

#### `:boolean` parser
Strips whitespace, downcases, then returns `true` if the resulting string is `'1'`, `'t'`, or `'true'`, `false` if the resulting string is `'0'`, `'f'`, or `'false'`, otherise it returns `nil`.

    column :price, as: :decimal
    '1' #=> true
    't' #=> true
    'T' #=> true
    'true' #=> true
    'TRUE' #=> true
    '0' #=> false
    'f' #=> false
    'F' #=> false
    'false' #=> false
    'FALSE' #=> false
    '2' #=> nil

#### `:date` parser
Strips all whitespace, parses with `Date.strptime`.

    column :date, as: :date
    '2017-01-01' #=> Date.parse('2017-01-01')

    column :date, as: :date, format: '%m/%d/%y'
    '12/31/17' #=> Date.strptime('12/31/2017', '%m/%d/%y')

Returns `nil` for unparseable values.

#### `:time` parser
Strips all whitespace, parses with `Time.strptime`.

    column :time, as: :time
    '2017-01-01 01:01:01 AM' #=> DateTime.parse('2017-01-01 01:01:01 AM')

    column :time, as: :time, format: '%m/%d/%y %I:%M:%S %p'
    '1/1/17 01:01:01 AM' #=> DateTime.parse('1/1/17 01:01:01 AM', '%m/%d/%y %I:%M:%S %p')

Returns `nil` for unparseable values.

#### Custom parser blocks
A block containing custom parsing logic can be used as well.

    column :rails_model do |value|
      Model.find(value)
    end

    column :rails_model { |value| Model.find(value) }

    column :rails_model, ->(value) { Model.find(value) }

#### Custom named parsers
A custom parser can be named for re-use across multiple columns. Just add a method with a name that ends in `_parser`.

    def dollars_to_cents_parser(value)
      (BigDecimal.new(value) * 100).to_i
    end

    column :price_in_cents, header: 'Price in $', as: :dollars_to_cents
    column :cost_in_cents, header: 'Cost in $', as: :dollars_to_cents

#### Reserved column names
An error will be thrown if trying to name a column `unparsed`, `csv_string`,
`row_number`, `skip_message`, or `abort_message`. This is because these will
automatically be appended to the `row` object that is passed to `rows`,
`skipped_rows`, and `aborted_rows` blocks.

    column :unparsed    # raises ReservedColumnName error
    column :csv_string  # raises ReservedColumnName error

#### Parsing `nil` and `blank` values
By default, CSVParty will intercept any values that are `nil` or which contain
only whitespace and coerce them to `nil` _without invoking the parser for that
column_. This applies to all parsers, including custom parsers which you
define, with one exception: the :raw parser. This is done as a convenience to
avoid pesky `NoMethodErrors` that arise when a parser tries to do its thing
to a `nil` value that it wasn't expecting. You can turn this behavior off on a
given column by setting `intercept_nils` to `false` in the options hash:

    class MyImporter < CSVParty
      column :price, header: 'Price', intercept_nils: false do |value|
        if value.nil?
          'n/a'
        else
          BigDecimal.new(value)
        end
      end
    end

## Rows
This is for specifying what happens with each row. It is required.

    rows do |row|
      # `row.column_name` for parsed column values
      # `row.unparsed.column_name` for unparsed column values
      # `row.csv_string` for the raw csv_string
      # `row.line_number` for the line in the CSV file
    end

## Files
This is for defining behavior that should happen before, after, or around
actually importing the rows in the file. It is optional.

    import do
      # do some stuff before importing rows
      import_rows!
      # do some stuff after importing rows
    end

## Errors
This is for gracefully handling errors that may arise in `column`, `rows`,
`import`, and `errors` blocks. It is optional. If no error handler is defined,
errors will simply be raised as they normally would.

    errors :ignore # silently ignore errors

    errors do |error, line_number, csv_string|
      # handle error
    end

## Dependencies
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

## Flow Control
Several flow control methods are available in `column`, `rows`, `import`,
and `errors` blocks:

#### `skip_row!`
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

#### `abort_row!`
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

#### `next_row!`
This silently stops importing the current row. It is intended to be used
in instances where processing is done for a given row. There is no way to
specify a handler.

    rows do |row|
      # this row is done being imported
      next_row!
    end

#### `abort_import!`
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

# Usage

## Specifying a CSV file to import
Since it just wraps the `CSV` class, there are three ways you can specify the
CSV file that you wish to import:

1. With a path to the file.

    importer = MyImporter.new('path/to/csv')
    # or
    importer = MyImporter.new
    importer.csv_path = 'path/to/csv'

2. With an IO object:

    importer = MyImporter.new(io_object)
    # or
    importer = MyImporter.new
    importer.csv_file = file

3. With a string:

    importer = MyImporter.new(string)
    # or
    importer = MyImporter.new
    importer.csv_string = string


Additionally, you can specify any options that the `CSV` class understands, with
the exception of `headers`, which will always be set to true. You can do that
like so:

    importer = MyImporter.new('path/to/csv', encoding: 'ISO-8859-1:UTF-8')
    importer.csv_options = { row_sep: '\n', encoding: 'ISO-8859-1:UTF-8' }
