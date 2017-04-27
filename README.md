[![Build Status](https://travis-ci.org/toasterlovin/csv_party.svg?branch=master)](https://travis-ci.org/toasterlovin/csv_party)

# Make importing CSV files a party

The point of this gem is to make it easier to focus on the business
logic of your CSV imports. You start by defining which columns you
will be importing, as well as how they will be parsed. Then, you
specify what you want to do with each row after it has been parsed.
That's it; CSVParty takes care of all the tedious stuff for you.

## Defining Columns

This is what defining your import columns look like:

    class MyImporter < CSVParty
      column :price, header: "Nonsensical Column Name", as: :decimal
    end

This will take the value in the "Nonsensical Column Name" column,
parse it as a decimal, then make it available to your import logic
as a nice, sane variable named `price`.

The available built-in parsers are:

  - `:raw` returns the value from the CSV file, unchanged
  - `:string` strips whitespace and returns the resulting string
  - `:integer` strips whitespace, then calls `to_i` on the resulting string
  - `:decimal` strips all characters except `0-9` and `.`, then passes the resulting string to `BigDecimal.new`
  - `:boolean` strips whitespace, downcases, then returns `true` if the resulting string is `'1'`, `'t'`, or `'true'`, otherwise it returns `false`

When defining a column, you can also pass a block if you need custom
parsing logic:

    class MyImporter < CSVParty
      column :product, header: "Product" do |value|
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

      column :price_in_cents, header: "Price in $", as: :dollars_to_cents
      column :cost_in_cents, header: "Cost in $", as: :dollars_to_cents
    end

NOTE: when using a custom parser to parse a column, the block or method that you
define has no way to reference the values from any other columns. So, this won't work:

    class MyImporter < CSVParty
      column :product, header: "Product", do |value|
        Product.find_by(name: value)
      end

      column :price, header: "Price", do |value|
        product.price = BigDecimal.new(value)  # product is not defined
      end
    end

Instead, you would accomplish this in your import logic.

## Defining Import Logic

Once you've defined all of your columns, you specify your import logic by passing a
block to the `import` DSL method. That block will have access to a `row` variable
which contains all of the parsed values for your columns. Here's what that looks like:

    class MyImporter < CSVParty
      import do |row|
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
      import do |row|
        row.price           # parsed value: #<BigDecimal:7f88d92cb820,'0.9E1',9(18)>
        row.unparsed.price  # unparsed value: "$9.00"
        row.string          # raw CSV string: "USB Cable,$9.00,Box,Blue"
      end
    end

## Importing

Once your importer class is defined, you use it like this:

    importer = MyImporter.new("path/to/file.csv")
    importer.import!

# Tested Rubies

CSVParty has been tested against the following Rubies:

MRI
- 2.2
- 2.1
- 2.0

# TODO

- Bug fix: line_number doesn't work on errors beyond the first
- Parse blank values as nil for custom parsers
- Inject dependencies
- Add error handling
  - Provide access to CSV file for error handling
  - Add error class that skips row
  - Add error class that aborts row
  - Add error class that aborts whole import
  - Allow options rather than blocks for common
    error handling strategies
- Re-enable class documentation cop
- Implement nil and blank value behavior for built-in parsers
- Add date parser
- Add date time parser
- Add mechanism for skipping rows (at both parser and import level)
- Throw errors when using reserved column names (`unparsed` & `csv_string`)
- Allow runtime configuration
