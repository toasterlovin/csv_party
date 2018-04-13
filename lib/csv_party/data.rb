module CSVParty
  module Data
    def csv_path=(path)
      raise_unless_argument_is_a('CSV path', path, String)
      raise NonexistentCSVFileError.new(path) unless File.file?(path)

      @_csv_data = File.open(path)
    end

    def csv_file=(file)
      raise_unless_argument_is_a('CSV file', file, IO)

      @_csv_data = file
    end

    def csv_content=(content)
      raise_unless_argument_is_a('CSV content', content, String)

      @_csv_data = content
    end

    def csv_options=(options)
      raise_unless_all_csv_options_are_recognized!(options)

      @_csv_options = options
    end

    private

    def initialize_csv!
      raise_unless_csv_data_is_present!

      @_csv_options[:headers] = true
      @_csv = CSV.new(@_csv_data, @_csv_options)
      @_csv.shift
      @_headers = @_csv.headers
      @_csv.rewind
    end

    def assign_csv_data_if_present(options)
      if options.has_key?(:path)
        self.csv_path = options.delete(:path)
      elsif options.has_key?(:file)
        self.csv_file = options.delete(:file)
      elsif options.has_key?(:content)
        self.csv_content = options.delete(:content)
      end
    end

    def assign_csv_options_if_present(options)
      self.csv_options = options.select do |option, _value|
        valid_csv_options.include?(option)
      end
    end

    def raise_unless_argument_is_a(name, argument, klass)
      return if argument.is_a?(klass)

      raise ArgumentError, <<-MESSAGE
#{name} should be a #{klass.name}, you passed an instance of #{argument.class.name}
      MESSAGE
    end

    def raise_unless_csv_data_is_present!
      return if defined?(@_csv_data)

      raise MissingCSVError.new(self)
    end

    def raise_unless_all_csv_options_are_recognized!(options)
      unrecognized_options = options.keys.reject do |option|
        valid_csv_options.include? option
      end
      return if unrecognized_options.empty?

      raise UnrecognizedCSVOptionsError.new(unrecognized_options,
                                            valid_csv_options)
    end

    def valid_data_options
      [:path, :file, :content]
    end

    def valid_csv_options
      CSV::DEFAULT_OPTIONS.keys
    end
  end
end
