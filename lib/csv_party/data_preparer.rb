module CSVParty
  DATA_OPTIONS = [:path, :file, :content].freeze
  CSV_OPTIONS = CSV::DEFAULT_OPTIONS.keys.freeze

  class DataPreparer
    def initialize(options)
      @options = options
    end

    def prepare
      raise_unless_csv_is_present!

      data = if @options.has_key?(:path)
               open_csv_path(@options[:path])
             elsif @options.has_key?(:file)
               @options[:file]
             elsif @options.has_key?(:content)
               @options[:content]
             end
      options = extract_csv_options.merge(headers: true)
      CSV.new(data, options)
    end

    private

    def open_csv_path(path)
      raise NonexistentCSVFileError.new(path) unless File.file?(path)

      File.open(path)
    end

    def extract_csv_options
      @options.select do |option, _value|
        CSV_OPTIONS.include?(option)
      end
    end

    def raise_unless_csv_is_present!
      return if DATA_OPTIONS.any? { |option| @options.has_key?(option) }

      raise MissingCSVError.new(self)
    end
  end
end
