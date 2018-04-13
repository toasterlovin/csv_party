require 'test_helper'

class ParserTest < Minitest::Test
  def test_raw_parser
    csv = <<-CSV
Raw,Surrounding Whitespace,Only Whitespace,Blank
some text, surrounding whitespace , ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :raw, as: :raw
      column :surrounding_whitespace, as: :raw
      column :only_whitespace, as: :raw
      column :blank, as: :raw

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal 'some text', importer.result.raw
    assert_equal ' surrounding whitespace ', importer.result.surrounding_whitespace
    assert_equal ' ', importer.result.only_whitespace
    assert_nil importer.result.blank
  end

  def test_string_parser
    csv = <<-CSV
String,Surrounding Whitespace,Only Whitespace,Blank
some text, surrounding whitespace , ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :string
      column :surrounding_whitespace
      column :only_whitespace
      column :blank

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal 'some text', importer.result.string
    assert_equal 'surrounding whitespace', importer.result.surrounding_whitespace
    assert_nil importer.result.only_whitespace
    assert_nil importer.result.blank
  end

  def test_boolean_parser
    csv = <<-CSV
T Lower,T Upper,True Lower,True Upper,One,True Surrounding Whitespace,F Lower,F Upper,False Lower,False Upper,Zero,False Surrounding Whitespace,Alpha String,Only Whitespace,Blank
t,T,true,TRUE,1, true ,f,F,false,FALSE,0, false ,asdf, ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :t_lower, as: :boolean
      column :t_upper, as: :boolean
      column :true_lower, as: :boolean
      column :true_upper, as: :boolean
      column :one, as: :boolean
      column :true_surrounding_whitespace, as: :boolean
      column :f_lower, as: :boolean
      column :f_upper, as: :boolean
      column :false_lower, as: :boolean
      column :false_upper, as: :boolean
      column :zero, as: :boolean
      column :false_surrounding_whitespace, as: :boolean
      column :alpha_string, as: :boolean
      column :only_whitespace, as: :boolean
      column :blank, as: :boolean

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert importer.result.t_lower
    assert importer.result.t_upper
    assert importer.result.true_lower
    assert importer.result.true_upper
    assert importer.result.one
    assert importer.result.true_surrounding_whitespace
    refute importer.result.f_lower
    refute importer.result.f_upper
    refute importer.result.false_lower
    refute importer.result.false_upper
    refute importer.result.zero
    refute importer.result.false_surrounding_whitespace
    assert_nil importer.result.alpha_string
    assert_nil importer.result.only_whitespace
    assert_nil importer.result.blank
  end

  def test_integer_parser
    csv = <<-CSV
Integer,Negative Integer,Negative Accounting Integer,Surrounding Whitespace,Decimal,Negative Decimal,Negative Accounting Decimal,Dollars,Negative Dollars,Negative Accounting Dollars,Whitespace Only,Blank
42,-42,(42), 42 ,42.42,-42.42,(42.42),$42,-$42,($42), ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :integer, as: :integer
      column :negative_integer, as: :integer
      column :negative_accounting_integer, as: :integer
      column :surrounding_whitespace, as: :integer
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
    end.new(content: csv)

    importer.import!

    assert_equal(42, importer.result.integer)
    assert_equal(-42, importer.result.negative_integer)
    assert_equal(-42, importer.result.negative_accounting_integer)
    assert_equal(42, importer.result.surrounding_whitespace)
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
Decimal,Negative Decimal,Negative Accounting Decimal,Surrounding Whitespace,Dollars,Negative Dollars,Negative Accounting Dollars,Whitespace Only,Blank
42.42,-42.42,(42.42), 42.42 ,$42.42,-$42.42,($42.42), ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :decimal, as: :decimal
      column :negative_decimal, as: :decimal
      column :negative_accounting_decimal, as: :decimal
      column :surrounding_whitespace, as: :decimal
      column :dollars, as: :decimal
      column :negative_dollars, as: :decimal
      column :negative_accounting_dollars, as: :decimal
      column :whitespace_only, as: :decimal
      column :blank, as: :decimal

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal(42.42, importer.result.decimal)
    assert_equal(-42.42, importer.result.negative_decimal)
    assert_equal(-42.42, importer.result.negative_accounting_decimal)
    assert_equal(42.42, importer.result.surrounding_whitespace)
    assert_equal(42.42, importer.result.dollars)
    assert_equal(-42.42, importer.result.negative_dollars)
    assert_equal(-42.42, importer.result.negative_accounting_dollars)
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_date_parser
    csv = <<-CSV
Date,Date With Format,Invalid Date,Invalid Format,Whitespace Only,Blank
2017-12-31,12/31/17,adsf,12/31/17, ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :date, as: :date
      column :date_with_format, as: :date, format: '%m/%d/%y'
      column :invalid_date, as: :date
      column :invalid_format, as: :date, format: 'asdf'
      column :whitespace_only, as: :date
      column :blank, as: :date

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal Date.new(2017, 12, 31), importer.result.date
    assert_equal Date.new(2017, 12, 31), importer.result.date_with_format
    assert_nil importer.result.invalid_date
    assert_nil importer.result.invalid_format
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_time_parser
    csv = <<-CSV
Time,Time With Timezone,Time With Format,Invalid Time,Invalid Format,Whitespace Only,Blank
2018-03-17T17:31:59,2018-03-17T17:31:59+04:00,3/17/18 @ 5:31 AM,asdf,2018-03-17T17:31:59+04:00, ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :time, as: :time
      column :time_with_timezone, as: :time
      column :time_with_format, as: :time, format: '%m/%d/%y @ %l:%M %p'
      column :invalid_time, as: :time
      column :invalid_format, as: :time, format: 'asdf'
      column :whitespace_only, as: :time
      column :blank, as: :time

      rows do |row|
        self.result = row
      end
    end.new(content: csv)

    importer.import!

    assert_equal Time.new(2018, 3, 17, 17, 31, 59, '+00:00'),
                 importer.result.time
    assert_equal Time.new(2018, 3, 17, 17, 31, 59, '+04:00'),
                 importer.result.time_with_timezone
    assert_equal Time.new(2018, 3, 17, 5, 31, 0, '+00:00'),
                 importer.result.time_with_format
    assert_nil importer.result.invalid_time
    assert_nil importer.result.invalid_format
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_custom_parser
    csv = <<-CSV
Custom,Whitespace Only,Blank
value,whitespace,blank
value, ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :custom do |value|
        "#{value} plus added text"
      end
      column :whitespace_only do
        'not nil'
      end
      column :blank do
        'not nil'
      end

      rows do |row|
        result << row
      end
    end.new(content: csv)

    importer.result = []
    importer.import!

    assert_equal 'value plus added text', importer.result[0].custom
    assert_equal 'not nil', importer.result[0].whitespace_only
    assert_equal 'not nil', importer.result[0].blank
    assert_nil importer.result[1].whitespace_only
    assert_nil importer.result[1].blank
  end

  def test_named_custom_parser
    csv = <<-CSV
Custom 1,Custom 2,Whitespace Only,Blank
value 1,value 2, ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :custom_1, as: :custom
      column :custom_2, as: :custom
      column :whitespace_only, as: :custom
      column :blank, as: :custom

      rows do |row|
        self.result = row
      end

      def custom_parser(value)
        "#{value} plus added text"
      end
    end.new(content: csv)

    importer.import!

    assert_equal 'value 1 plus added text', importer.result.custom_1
    assert_equal 'value 2 plus added text', importer.result.custom_2
    assert_nil importer.result.whitespace_only
    assert_nil importer.result.blank
  end

  def test_intercept_blank_values
    csv = <<-CSV
Intercept,No Intercept,Third Column
 , ,
    CSV

    importer = Class.new(CSVParty::Importer) do
      column :intercept, as: :static
      column :no_intercept, intercept_blanks: false, as: :static

      rows do |row|
        self.result = row
      end

      def static_parser(_value)
        return 'Not nil'
      end
    end.new(content: csv)

    importer.import!

    assert_nil importer.result.intercept
    assert_equal 'Not nil', importer.result.no_intercept
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
    end.new(content: csv)

    assert_raises CSVParty::UnknownParserError do
      importer.import!
    end
  end
end
