class BetterCsv
  # The point of this gem is to make it possible to focus on the logic
  # of your CSV imports, rather than on the housekeeping. The general
  # idea is that you first define which columns you will be importing,
  # as well as how they will be parsed. Then, you specify what you want
  # to do with each row after the values for that row have been parsed.
  #
  # This is what defining your import columns look like:
  #
  #   column :price, header: "Krazy Price Column", as: :decimal
  #
  # This will take the value in the "Krazy Price Column" column,
  # parse it as a decimal, then make it available to your import logic
  # as a nice, sane variable named `price`.
  #
  # You can also pass a block when defining a column if your parsing
  # logic needs to be a little more sophisticated than the built-in
  # methods:
  #
  #   class MyImporter < BetterCsv
  #     class :product, header: "Product" do |value|
  #       Product.find_by(name: value.strip)
  #     end
  #   end
  #
  # Once you've defined all of your columns, you define your import logic.
  # Here's what that looks like:
  #
  #   class MyImporter < BetterCsv
  #     import do |row|
  #       row.price           # access parsed values
  #       row.values.price    # access raw values
  #     end
  #   end

  PARSERS = [:boolean, :integer, :decimal, :string, :raw]

  @@columns = {}
  @@importer

  def self.column(name, options, &block)
    header = options[:header]
    raise ArgumentError, "A header must be specified for #{name}" unless header

    if block_given?
      parser = block
    else
      parser_name = options[:as]
      raise ArgumentError, "The parser for #{name} must be one of #{PARSERS.join(", ")}" unless PARSERS.include? parser_name
      parser = Proc.new { |value| send(:"#{parser_name}_parser", value) }
    end

    @@columns[name] = { header: header, parser: parser }
  end

  def self.import(&block)
    @@importer = block
  end

  def initialize(csv_path)
    @csv_path = csv_path
  end

  def import!
    CSV.foreach(@csv_path) do |row|
      parsed_row = parse_row(row)
      import_row(parsed_row)
    end
  end


  private

  def boolean_parser(value)
    [true, 1, 'true'].include? value.strip.downcase
  end

  def integer_parser(value)
    value.to_i
  end

  def decimal_parser(value)
    BigDecimal.new(value.strip)
  end

  def string_parser(value)
    value.strip
  end

  def raw_parser(value)
    value
  end
end
