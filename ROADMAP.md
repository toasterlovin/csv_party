Roadmap
-

## 1.1 Stop execution before a row is fully parsed

Currently, CSVParty is pretty well thought out about what should happen when
either 1) one of the built in flow control methods (`next_row`, `skip_row`,
`abort_row`, and `abort_import`) is used, or 2) an error is raised while
the row importer block is being executed. However, all of these things can also
happen when the columns for a row are being parsed. When/if it does, most of the
flow control and error handling kind of assumes that the row has been fully
parsed. So some design work should go into deciding what should happen in these
cases. And then tests should be written for all of the various scenarios.

## 1.2 Convert row object into hash

One of the primary use cases for importing CSV files is to insert their contents
into a database. Apparently this is common enough that the [csv-importer][] gem,
which almost completely automates this process without much room for
customization, is very popular. So, in the case where there is a pretty simple
correspondence between the contents of a CSV file and ActiveRecord models, it
should be dead simple to get the job done.

[csv-importer](https://github.com/pcreux/csv-importer)

What I have in mind is something like:

    class MyImporter < CSVParty::Importer
      column :product_id
      column :quantity
      column :price

      rows do |row|
        LineItem.create(row.attributes)
      end
    end

Where `row.attributes` returns a hash with all of the column names as keys and
all of the parsed values as values. So, with an importer like the one above,
`row.attributes` would return a hash like so:

    { product_id: 42, quantity: 3, price: 9.99 }

## 1.3 Export skipped/aborted rows as CSV files

Most user inputs to an application are relatively constrained. CSV files, on the
other hand, are not. Users can, and will, put all kinds of erroneous data into
their CSV files. So, it is useful to be able to provide a user with a list of
the rows in their file that could not be imported, so that they can re-import
these rows after they have resolved whatever issues existed. And CSV is a
natural format for this, since the user can open the file in Excel and make
edits.

A motivated user of CSVParty can already achieve this by accessing the
`skipped_rows`, `aborted_rows`, and `error_rows` arrays and constructing one or
more CSV files from these, but it would be nice to provide a default
implementation that is only a method call away. What I have in mind is for the
CSV file that is created to have the exact same column structure as the original
file, but with three additional columns:

  - The original row number
  - The status (skipped, aborted, errored)
  - A message explaining the reason for the status

Conveniently, all of these pieces of data are available for skipped, aborted,
and errored rows. Then, the file would be generated with a method, like so:

    # all three combined
    importer.unimported_rows_as_csv
    # or separate
    importer.skipped_rows_as_csv
    importer.aborted_rows_as_csv
    importer.error_rows_as_csv

## 1.4 Batch API

It can be way more performant to batch imports so that expensive operations,
like persisting data, are only done every so often. This would add an API to
accumulate data, execute some logic every X number of rows, reset the
accumulators, then repeat.

    rows do |row|
      customers[row.customer_id] = { name: row.customer_name, phone: row.phone }
      orders << { customer_id: row.customer_id, invoice_number: row.invoice_number }
    end

    batch 50, customers: {}, orders: [] do
      # insert customers into database
      # insert orders into database

      # accumulators are automatically reset to their initial values after the
      # batch block is done executing
    end

    # accumulators are optional, they are functionally identical to doing

    class MyImporter < CSVParty::Importer
      attr_accessor :customers, :orders

      def customers
        @customers ||= {}
      end

      def orders
        @orders ||= []
      end

      rows do |row|
        customers << row.customer
        orders << row.order
      end

      batch 50 do
        # insert customers into database
        # insert orders into database
        customers = {}
        orders = []
      end
    end

## 1.5 Runtime configuration

    my_importer = MyImporter.new
    my_importer.configure do
      column :price, as: :decimal
      rows do |row|
        # import row
      end
    end

## 1.6 CSV parse error handling
Default behavior is to raise as normal.

    parse_errors :ignore # to do nothing

    parse_errors do |line_number|
      # handle parse error
    end

    my_import.aborted_rows # returns array of parse error rows

# Someday

## Allow specifying columns by column number rather than header text

## Allow using multiple columns to generate one variable

    column :total, header: ['Price', 'Quantity'] do |price, quantity|
      BigDecimal.new(price) * BigDecimal.new(quantity)
    end
