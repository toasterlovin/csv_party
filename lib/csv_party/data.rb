module CSVParty
  module Data
    def csv=(csv)
      @_csv_file = if csv.nil?
                     nil
                   else
                     prepare_csv(csv)
                   end
    end

    def csv_options=(options)
      raise_unless_all_csv_options_are_recognized!(options)

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

    def prepare_csv(csv)
      if csv.is_a?(IO)
        csv
      elsif csv.is_a?(String)
        prepare_csv_from_string(csv)
      else
        raise InvalidCSVError.new(csv)
      end
    end

    def prepare_csv_from_string(csv_string)
      return csv_string if csv_string.lines.count > 1

      open_csv_from_path(csv_string)
    end

    def open_csv_from_path(file_path)
      raise NonexistentCSVFileError.new(file_path) unless File.file?(file_path)

      File.open(file_path)
    end

    def raise_unless_all_csv_options_are_recognized!(options)
      unrecognized_options = options.keys.reject do |option|
        valid_csv_options.include? option
      end
      return if unrecognized_options.empty?

      raise UnrecognizedCSVOptionsError.new(unrecognized_options,
                                            valid_csv_options)
    end

    def valid_csv_options
      CSV::DEFAULT_OPTIONS.keys
    end
  end
end
