module CSVParty
  module Data
    def csv=(csv)
      @_csv_file = if csv.is_a?(IO)
                     csv
                   elsif csv.is_a?(String) && csv.lines.count == 1
                     File.open(csv)
                   elsif csv.is_a?(String)
                     csv
                   end
    end

    def csv_options=(options)
      @_csv_options = options
    end

    private

    def initialize_csv_data!
      raise_unless_csv_data_is_present!

      @_csv_options[:headers] = true
      @_csv = CSV.new(@_csv_file, @_csv_options)
      @_csv.shift
      @_headers = @_csv.headers
      @_csv.rewind
    end

    def raise_unless_csv_data_is_present!
      return if @_csv_file

      raise CSVParty::MissingCSVError, <<-MSG
You must specify a filepath, IO object, or string to import:

    # Filepath, IO object, or string
    csv = 'path/to/csv'
    csv = File.open('path/to/csv')
    csv = 'Header1,Header2\\nvalue1,value2\\n'

Then, you assign that to your importer one of two ways:

    importer = MyImporter.new(csv)
    # or
    importer = MyImporter.new
    importer.csv = csv
      MSG
    end
  end
end
