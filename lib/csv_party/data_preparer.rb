require 'csv'
require 'csv_party/errors'

module CSVParty
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
      CSV.new(data, **options)
    end

    private

    def open_csv_path(path)
      raise NonexistentCSVFileError.new(path) unless File.file?(path)

      if @options.has_key?(:encoding)
        File.open(path, "r:#{@options[:encoding]}")
      else
        File.open(path)
      end
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
