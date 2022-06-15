[![Gem Version](https://badge.fury.io/rb/csv_party.svg)](https://badge.fury.io/rb/csv_party)
[![Build Status](https://travis-ci.org/toasterlovin/csv_party.svg?branch=master)](https://travis-ci.org/toasterlovin/csv_party)
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/946d0dec172fda05d631/maintainability)](https://codeclimate.com/github/toasterlovin/csv_party/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/946d0dec172fda05d631/test_coverage)](https://codeclimate.com/github/toasterlovin/csv_party/test_coverage)

# Make importing CSV files a party

The point of this gem is to make it easier to focus on the business
logic of your CSV imports. You start by defining which columns you
will be importing, as well as how they will be parsed. Then, you
specify what you want to do with each row after it has been parsed.
That's it; CSVParty takes care of all the tedious stuff for you.

## Defining Columns

This is what defining your import columns look like:

    class MyImporter < CSVParty
      column :price, header: 'Nonsensical Column Name', as: :decimal
    end

This will take the value in the 'Nonsensical Column Name' column,
parse it as a decimal, then make it available to your import logic
as a nice, sane variable named `price`.

The available built-in parsers are:

  - `:raw` returns the value from the CSV file, unchanged
  - `:string` strips whitespace and returns the resulting string
  - `:integer` strips whitespace, then calls `to_i` on the resulting string
  - `:decimal` strips all characters except `0-9` and `.`, then passes the
    resulting string to `BigDecimal.new`
  - `:boolean` strips whitespace, downcases, then returns `true` if the
    resulting string is `'1'`, `'t'`, or `'true'`, otherwise it returns `false`

When defining a column, you can also pass a block if you need custom
parsing logic:

    class MyImporter < CSVParty
      column :product, header: 'Product' do |value|
        Product.find_by(name: value)
      end
    end

Or, if you want to re-use a custom parser for multiple columns, just
define a method on your class with a name that ends in `_parser` and
you can use it the same way you use the built-in parsers:

    class MyImporter < CSVParty
      def dollars_to_cents_parser(value)
        (BigDecimal.new(value) * 100).to_i
      end

      column :price_in_cents, header: 'Price in $', as: :dollars_to_cents
      column :cost_in_cents, header: 'Cost in $', as: :dollars_to_cents
    end

#### NOTE: Parsing nil and blank values

By default, CSVParty will intercept any values that are `nil` or which contain
only whitespace and coerce them to `nil` _without invoking the parser for that
column_. This applies to all parsers, including custom parsers which you
define, with one exception: the :raw parser. This is done as a convenience to
avoid pesky `NoMethodError`s that arise when a parser tries to do its thing
to a `nil` value that it wasn't expecting. You can turn this behavior off on a
given column by setting `intercept_blanks` to `false` in the options hash:

    class MyImporter < CSVParty
      column :price, header: 'Price', intercept_blanks: false do |value|
        if value.nil?
          'n/a'
        else
          BigDecimal.new(value)
        end
      end
    end

#### NOTE: Parsers cannot reference each other

When using a custom parser to parse a column, the block or method that you
define has no way to reference the values from any other columns. So, this won't
work:

    class MyImporter < CSVParty
      column :product, header: 'Product', do |value|
        Product.find_by(name: value)
      end

      column :price, header: 'Price', do |value|
        # product is not defined...
        product.price = BigDecimal.new(value)
      end
    end

Instead, you would do this in your row import logic. Which brings us to:

## Importing Rows

Once you've defined all of your columns, you specify your logic for importing
rows by passing a block to the `rows` DSL method. That block will have access
to a `row` variable which contains all of the parsed values for your columns.
Here's what that looks like:

    class MyImporter < CSVParty
      rows do |row|
        product = row.product
        product.price = row.price
        product.save
      end
    end

The `row` variable also provides access to two other things:

- The unparsed values for your columns
- The raw CSV string for that row

Here's how you access those:

    class MyImporter < CSVParty
      rows do |row|
        row.price           # parsed value: #<BigDecimal:7f88d92cb820,'0.9E1',9(18)>
        row.unparsed.price  # unparsed value: '$9.00'
        row.string          # raw CSV string: 'USB Cable,$9.00,Box,Blue'
      end
    end

## Importing

Once your importer class is defined, you use it like this:

    importer = MyImporter.new('path/to/file.csv')
    importer.import!

You can also specify what should happen before and after your import by passing
a block to `import`, like so:

    class MyImporter < CSVParty
      # column definitions
      # row import logic

      import do
        puts 'Starting import'
        import_rows!
        puts 'Import finished!'
      end
    end

You can do whatever you want inside of the `import` block, just make sure to
call `import_rows!` somewhere in there.

## Handling Errors

One of the hallmarks of importing data from CSV files is that there are
inevitably rows with errors of some kind. You can handle error rows by
specifying an `errors` block:

    class MyImporter < CSVParty
      # column definitions
      # row import logic

      errors do |error, line_number|
        # log error
      end
    end

Any row in your CSV file which results in an exception will be passed to this
block. Which means you can specify that there is an error with a given row by
raising an exception:

    rows do |row|
      # rows with price less than 0 will be treated as errors
      raise if row.price < 0
    end

## External Dependencies

Sometimes you need access to external objects in your importer's logic. You can specify
what external objects your importer depends on with `depends_on`. Dependencies declared
this way will then be available in your parsers and your `rows`, `import`, and `errors`
blocks:

    class MyImporter < CSVParty
      # column definitions...

      depends_on: :product_import

      rows do |row|
        # do some stuff

        # product_import is not provided by the class,
        # but is passed in at runtime instead!
        product_import.log_success(product)
      end
    end

Then, to pass the dependency in at runtime, you just add an option to `.new` with
the name and value of the dependency:

    MyImporter.new(
      'path/to/csv',
       product_import: @product_import
    )

# Tested Rubies

CSVParty has been tested against the following Rubies:

MRI
- 3.1
- 3.0
- 2.7
- 2.6

# License

This project uses the MIT License. See LICENSE.md for details.
