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

      raise MissingCSVError.new(self)
    end
  end
end
