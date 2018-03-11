module CSVParty
  module DSL
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def column(column, options, &block)
        raise_if_duplicate_column(column)
        raise_if_missing_header(column, options)

        options = {
          blanks_as_nil: (options[:as] == :raw ? false : true),
          as: :string
        }.merge(options)

        parser = if block_given?
                   block
                 else
                   "#{options[:as]}_parser".to_sym
                 end

        columns[column] = {
          header: options[:header],
          parser: parser,
          blanks_as_nil: options[:blanks_as_nil]
        }
      end

      def rows(&block)
        @row_importer = block
      end

      def import(&block)
        @importer = block
      end

      def errors(&block)
        @error_processor = block
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

      def error_processor
        @error_processor ||= nil
      end

      private

      def raise_if_duplicate_column(name)
        return unless columns.has_key?(name)

        raise DuplicateColumnError, "A column named :#{name} has already been \
                defined, choose a different name"
      end

      def raise_if_missing_header(name, options)
        return if options.has_key?(:header)

        raise MissingHeaderError, "A header must be specified for #{name}"
      end
    end
  end
end
