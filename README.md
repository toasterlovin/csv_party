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
        Product.find_by(name: value.strip)
      end
    end

Or, if you want to re-use a custom parser for multiple columns, just
define a method on your class with a name that ends in `_parser` and
you can use it the same way you use the built-in parsers:

    class MyImporter < CSVParty
      def dollar_to_cents_parser(value)
        (BigDecimal.new(value) * 100).to_i
      end

      column :price_in_cents, header: "Price in $", as: :dollars_to_cents
      column :cost_in_cents, header: "Cost in $", as: :dollars_to_cents
    end

## Defining Import Logic

Once you've defined all of your columns, you define your import logic:

    class MyImporter < CSVParty
      import do |row|
        row.price           # access parsed values
        row.values.price    # access raw values
      end
    end

# TODO

- Investigate better ways to pass parsers around
- Make values available as `row.value`, rather than `row[:value]`
- Implement raw value access from import block (`row.values.value`)
- Add tests
- Add error handling
- Allow runtime configuration
