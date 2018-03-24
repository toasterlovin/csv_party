module CSVParty
  module DSL
    RESERVED_COLUMN_NAMES = [:unparsed, :csv_string, :row_number].freeze

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def column(column, options = {}, &block)
        raise_if_duplicate_column(column)
        raise_if_reserved_column_name(column)

        options = {
          header: column_regex(column),
          as: :string,
          format: nil,
          intercept_blanks: (options[:as] == :raw ? false : true)
        }.merge(options)

        parser = if block_given?
                   block
                 else
                   "#{options[:as]}_parser".to_sym
                 end

        columns[column] = {
          header: options[:header],
          parser: parser,
          format: options[:format],
          intercept_blanks: options[:intercept_blanks]
        }
      end

      def rows(&block)
        @row_importer = block
      end

      def import(&block)
        @importer = block
      end

      def errors(setting = nil, &block)
        @error_handler = setting || block
      end

      def skipped_rows(setting = nil, &block)
        @skipped_row_handler = setting || block
      end

      def depends_on(*args)
        args.each do |arg|
          dependencies << arg
          attr_accessor arg
        end
      end

      def dependencies
        @dependencies ||= []
      end

      def columns
        @columns ||= {}
      end

      def row_importer
        @row_importer ||= nil
      end

      def importer
        @importer ||= nil
      end

      def error_handler
        @error_handler ||= nil
      end

      def skipped_row_handler
        @skipped_row_handler ||= nil
      end

      private

      def column_regex(column)
        column = Regexp.escape(column.to_s)
        underscored_or_whitespaced = "#{column}|#{column.tr('_', ' ')}"
        /\A\s*#{underscored_or_whitespaced}\s*\z/i
      end

      def raise_if_duplicate_column(name)
        return unless columns.has_key?(name)

        raise DuplicateColumnError, "A column named :#{name} has already been \
                defined, choose a different name."
      end

      def raise_if_reserved_column_name(column)
        return unless RESERVED_COLUMN_NAMES.include? column

        raise ReservedColumnNameError, <<-MSG
The following column names are reserved for interal use, please use a different
column name: #{RESERVED_COLUMN_NAMES.join(', ')}.
        MSG
      end
    end
  end
end
