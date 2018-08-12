module CSVParty
  module Validations
    def raise_unless_row_processor_is_defined!
      return if config.row_importer

      raise UndefinedRowProcessorError.new
    end

    def raise_unless_rows_have_been_imported!
      return if @_rows_have_been_imported

      raise UnimportedRowsError.new
    end

    def raise_unless_all_dependencies_are_present!
      config.dependencies.each do |dependency|
        next unless importer.send(dependency).nil?

        raise MissingDependencyError.new(self, dependency)
      end
    end

    # This error has to be raised at runtime because, when the class body
    # is being executed, the parser methods won't be available unless
    # they are defined above the column definitions in the class body
    def raise_unless_all_named_parsers_exist!
      config.columns_with_named_parsers.each do |name, options|
        parser = options[:parser]
        next if named_parsers.include? parser

        raise UnknownParserError.new(name, parser, named_parsers)
      end
    end

    def raise_unless_csv_has_all_columns!
      return if missing_columns.empty?

      raise MissingColumnError.new(present_columns, missing_columns)
    end
  end
end
