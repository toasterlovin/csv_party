module CSVParty
  class Configuration
    attr_accessor :row_importer, :file_importer, :error_handler,
                  :skipped_row_handler, :aborted_row_handler

    attr_reader :columns, :dependencies

    def initialize
      @columns = {}
      @dependencies = []
    end

    def add_column(column, options = {}, &block)
      raise_if_duplicate_column(column)
      raise_if_reserved_column_name(column)

      options = {
        header: column_regex(column),
        as: :string,
        format: nil,
        intercept_blanks: (options[:as] != :raw)
      }.merge(options)

      parser = if block_given?
                 block
               else
                 "parse_#{options[:as]}".to_sym
               end

      columns[column] = {
        header: options[:header],
        parser: parser,
        format: options[:format],
        intercept_blanks: options[:intercept_blanks]
      }
    end

    def add_dependency(*args)
      args.each do |arg|
        dependencies << arg
      end
    end

    def columns_with_named_parsers
      columns.select { |_name, options| options[:parser].is_a? Symbol }
    end

    def columns_with_regex_headers
      columns.select { |_name, options| options[:header].is_a? Regexp }
    end

    def required_columns
      columns.map { |_name, options| options[:header] }
    end

    private

    def column_regex(column)
      column = Regexp.escape(column.to_s)
      underscored_or_whitespaced = "#{column}|#{column.tr('_', ' ')}"
      /\A\s*#{underscored_or_whitespaced}\s*\z/i
    end

    def raise_if_duplicate_column(name)
      return unless columns.has_key?(name)

      raise DuplicateColumnError.new(name)
    end

    RESERVED_COLUMN_NAMES = [:unparsed,
                             :csv_string,
                             :row_number,
                             :skip_message,
                             :abort_message].freeze

    def raise_if_reserved_column_name(column)
      return unless RESERVED_COLUMN_NAMES.include? column

      raise ReservedColumnNameError.new(RESERVED_COLUMN_NAMES)
    end
  end
end
