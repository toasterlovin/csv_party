module CSVParty
  module Data
    attr_accessor :csv

    private

    def initialize_csv(options)
      raise_unless_csv_is_present!(options)

      data = if options.has_key?(:path)
               open_csv_path(options[:path])
             elsif options.has_key?(:file)
               options[:file]
             elsif options.has_key?(:content)
               options[:content]
             end
      options = extract_csv_options(options).merge(headers: true)
      self.csv = CSV.new(data, options)
    end

    def open_csv_path(path)
      raise NonexistentCSVFileError.new(path) unless File.file?(path)

      File.open(path)
    end

    def extract_csv_options(options)
      options.select do |option, _value|
        valid_csv_options.include?(option)
      end
    end

    def raise_unless_csv_is_present!(options)
      return if valid_data_options.any? { |option| options.has_key?(option) }

      raise MissingCSVError.new(self)
    end

    def valid_data_options
      [:path, :file, :content]
    end

    def valid_csv_options
      CSV::DEFAULT_OPTIONS.keys
    end
  end
end
