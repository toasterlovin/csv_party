require 'test_helper'

class ParserTest < Minitest::Test
  def test_raw_parser
    csv = <<-CSV
Raw,Second Column
 has whitespace ,some text
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :raw, as: :raw
      column :second_column, as: :raw

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal ' has whitespace ', importer.result.raw
  end

  def test_string_parser
    csv = <<-CSV
String,Second Column
 has whitespace ,some text
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :string, as: :string
      column :second_column, as: :string

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal 'has whitespace', importer.result.string
  end

  def test_boolean_parser
    csv = <<-CSV
t,T,true,TRUE,one,true whitespace,f,F,false,FALSE,zero,false whitespace,random
t,T,true,TRUE,1, true ,f,F,false,FALSE,0, false ,asdf
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :t, as: :boolean
      column :T, as: :boolean
      column :true, as: :boolean
      column :TRUE, as: :boolean
      column :one, as: :boolean
      column :true_whitespace, as: :boolean
      column :f, as: :boolean
      column :F, as: :boolean
      column :false, as: :boolean
      column :FALSE, as: :boolean
      column :zero, as: :boolean
      column :false_whitespace, as: :boolean
      column :random, as: :boolean

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert importer.result.t
    assert importer.result.T
    assert importer.result.true
    assert importer.result.TRUE
    assert importer.result.one
    assert importer.result.true_whitespace
    refute importer.result.f
    refute importer.result.F
    refute importer.result.false
    refute importer.result.FALSE
    refute importer.result.zero
    refute importer.result.false_whitespace
    assert_nil importer.result.random
  end

  def test_integer_parser
    csv = <<-CSV
Integer,Negative Integer,Negative Accounting Integer,Whitespace,Decimal,Negative Decimal,Negative Accounting Decimal,Dollars,Negative Dollars,Negative Accounting Dollars,Whitespace Only,Blank
42,-42,(42), 42 ,42.42,-42.42,(42.42),$42,-$42,($42),  ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :integer, as: :integer
      column :negative_integer, as: :integer
      column :negative_accounting_integer, as: :integer
      column :whitespace, as: :integer
      column :decimal, as: :integer
      column :negative_decimal, as: :integer
      column :negative_accounting_decimal, as: :integer
      column :dollars, as: :integer
      column :negative_dollars, as: :integer
      column :negative_accounting_dollars, as: :integer
      column :whitespace_only, as: :integer
      column :blank, as: :integer

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal(42, importer.result.integer)
    assert_equal(-42, importer.result.negative_integer)
    assert_equal(-42, importer.result.negative_accounting_integer)
    assert_equal(42, importer.result.whitespace)
    assert_equal(42, importer.result.decimal)
    assert_equal(-42, importer.result.negative_decimal)
    assert_equal(-42, importer.result.negative_accounting_decimal)
    assert_equal(42, importer.result.dollars)
    assert_equal(-42, importer.result.negative_dollars)
    assert_equal(-42, importer.result.negative_accounting_dollars)
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_decimal_parser
    csv = <<-CSV
Decimal,Negative Decimal,Negative Accounting Decimal,Whitespace,Dollars,Negative Dollars,Negative Accounting Dollars
42.42,-42.42,(42.42), 42.42 ,$42.42,-$42.42,($42.42)
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :decimal, as: :decimal
      column :negative_decimal, as: :decimal
      column :negative_accounting_decimal, as: :decimal
      column :whitespace, as: :decimal
      column :dollars, as: :decimal
      column :negative_dollars, as: :decimal
      column :negative_accounting_dollars, as: :decimal

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal(42.42, importer.result.decimal)
    assert_equal(-42.42, importer.result.negative_decimal)
    assert_equal(-42.42, importer.result.negative_accounting_decimal)
    assert_equal(42.42, importer.result.whitespace)
    assert_equal(42.42, importer.result.dollars)
    assert_equal(-42.42, importer.result.negative_dollars)
    assert_equal(-42.42, importer.result.negative_accounting_dollars)
  end

  def test_date_parser
    csv = <<-CSV
date,date with format,invalid date,invalid format
2017-12-31,12/31/17,adsf,12/31/17
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :date, as: :date
      column :date_with_format, as: :date, format: '%m/%d/%y'
      column :invalid_date, as: :date
      column :invalid_format, as: :date, format: 'asdf'

      rows do |row|
        self.result = row
      end

      errors do |error|
        raise error
      end
    end.new(csv)

    importer.import!

    assert_equal Date.new(2017, 12, 31), importer.result.date
    assert_equal Date.new(2017, 12, 31), importer.result.date_with_format
    assert_nil importer.result.invalid_date
    assert_nil importer.result.invalid_format
  end

  def test_time_parser
    csv = <<-CSV
time,time with timezone,time with format,invalid time,invalid format
2018-03-17T17:31:59,2018-03-17T17:31:59+04:00,3/17/18 @ 5:31 AM,asdf,2018-03-17T17:31:59+04:00
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :time, as: :time
      column :time_with_timezone, as: :time
      column :time_with_format, as: :time, format: '%m/%d/%y @ %l:%M %p'
      column :invalid_time, as: :time
      column :invalid_format, as: :time, format: 'asdf'

      rows do |row|
        self.result = row
      end

      errors do |error|
        raise error
      end
    end.new(csv)

    importer.import!

    assert_equal Time.new(2018, 3, 17, 17, 31, 59, '+00:00'),
                 importer.result.time
    assert_equal Time.new(2018, 3, 17, 17, 31, 59, '+04:00'),
                 importer.result.time_with_timezone
    assert_equal Time.new(2018, 3, 17, 5, 31, 0, '+00:00'),
                 importer.result.time_with_format
    assert_nil importer.result.invalid_time
    assert_nil importer.result.invalid_format
  end

  def test_custom_parser
    csv = <<-CSV
Custom
value
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :custom do |value|
        "#{value} plus added text"
      end

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal 'value plus added text', importer.result.custom
  end

  def test_named_custom_parser
    csv = <<-CSV
Custom 1,Custom 2
value 1,value 2
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :custom_1, as: :custom
      column :custom_2, as: :custom

      rows do |row|
        self.result = row
      end

      def custom_parser(value)
        "#{value} plus added text"
      end
    end.new(csv)

    importer.import!

    assert_equal 'value 1 plus added text', importer.result.custom_1
    assert_equal 'value 2 plus added text', importer.result.custom_2
  end

  def test_parses_as_string_by_default
    csv = <<-CSV
Whitespace,Second Column
 removed whitespace ,value
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :whitespace, header: 'Whitespace'

      rows do |row|
        self.result = row
      end
    end.new(csv)

    importer.import!

    assert_equal 'removed whitespace', importer.result.whitespace
  end

  def test_intercept_blank_values
    csv = <<-CSV
Empty,Blank,Integer,Decimal,Boolean,Date,Time,Raw Blank,Custom,Opt Out
, ,,,,,, ,,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :empty, as: :string
      column :blank, as: :string
      column :integer, as: :integer
      column :decimal, as: :decimal
      column :boolean, as: :boolean
      column :date, as: :date
      column :time, as: :time
      column :raw_blank, as: :raw
      column :custom do
        'Not nil'
      end
      column :opt_out, intercept_blanks: false do
        'Not nil'
      end

      rows do |row|
        self.result = row
      end

      errors do |error|
        raise error
      end
    end.new(csv)

    importer.import!

    assert_nil importer.result.empty
    assert_nil importer.result.blank
    assert_nil importer.result.integer
    assert_nil importer.result.decimal
    assert_nil importer.result.boolean
    assert_nil importer.result.date
    assert_nil importer.result.time
    assert_equal ' ', importer.result.raw_blank
    assert_nil importer.result.custom
    assert_equal 'Not nil', importer.result.opt_out
  end

  def test_unknown_named_parser
    csv = <<-CSV
Custom,Header2
value1,value2
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :custom, as: :mispelled

      rows do
      end

      def custom_parser(value)
        "#{value} plus some text"
      end
    end.new(csv)

    assert_raises CSVParty::UnknownParserError do
      importer.import!
    end
  end
end
