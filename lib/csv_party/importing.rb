module CSVParty
  module Importing
    attr_accessor :columns, :row_importer, :importer,
                  :error_processor, :dependencies

    attr_reader :imported_rows, :skipped_rows, :aborted_rows, :error_rows,
                :abort_message, :rows_have_been_imported

    def import!
      if importer
        instance_exec(&importer)
        raise_unless_rows_have_been_imported!
      else
        import_rows!
      end
    rescue AbortedImportError => error
      @aborted = true
      @abort_message = error.message
    end

    def import_rows!
      raise_unless_row_processor_is_defined!

      loop do
        begin
          row = @csv.shift
          break unless row
          import_row!(row)
          imported_rows << @csv.lineno
        rescue SkippedRowError
          skipped_rows << @csv.lineno
        rescue AbortedImportError
          raise
        rescue CSV::MalformedCSVError
          raise
        rescue StandardError => error
          process_error(error, @csv.lineno, row.to_csv)
          aborted_rows << @csv.lineno
        end
      end

      @rows_have_been_imported = true
    end

    def aborted?
      @aborted
    end

    def skip_row
      raise SkippedRowError
    end

    def abort_row(message)
      raise AbortedRowError, message
    end

    def abort_import(message)
      raise AbortedImportError, message
    end

    private

    def import_row!(row)
      parsed_row = parse_row(row)
      instance_exec(parsed_row, &row_importer)
    end

    def parse_row(row)
      parsed_row = extract_parsed_values(row)
      parsed_row[:unparsed] = extract_unparsed_values(row)
      parsed_row[:csv_string] = row.to_csv

      return parsed_row
    end

    def extract_unparsed_values(row)
      unparsed_row = blank_unparsed_row_struct
      columns.each do |column, options|
        header = options[:header]
        unparsed_row[column] = row[header]
      end

      return unparsed_row
    end

    def extract_parsed_values(row)
      parsed_row = blank_parsed_row_struct
      columns.each do |column, options|
        header = options[:header]
        value = row[header]
        parsed_row[column] = parse_value(value, options)
      end

      return parsed_row
    end

    def parse_value(value, options)
      return nil if options[:intercept_blanks] && is_blank?(value)

      parser = options[:parser]

      if parser.is_a?(Symbol)
        parse_with_method(value, options)
      else
        parse_with_block(value, options)
      end
    end

    def parse_with_method(value, options)
      format = options[:format]
      parser = options[:parser]

      if format.nil?
        send(parser, value)
      else
        send(parser, value, format)
      end
    end

    def parse_with_block(value, options)
      parser = options[:parser]

      instance_exec(value, &parser)
    end

    def blank_parsed_row_struct
      Struct.new(*columns.keys, :unparsed, :csv_string).new
    end

    def blank_unparsed_row_struct
      Struct.new(*columns.keys).new
    end

    def is_blank?(value)
      value.nil? || value.strip.empty?
    end

    def process_error(error, line_number, csv_string)
      raise error unless error_processor

      if error_processor == :ignore
        error_rows << error_struct(error, line_number, csv_string)
      else
        instance_exec(error, line_number, csv_string, &error_processor)
      end
    end

    def error_struct(error, line_number, csv_string)
      Struct.new(:error, :line_number, :csv_string)
            .new(error, line_number, csv_string)
    end

    def raise_unless_row_processor_is_defined!
      return if row_importer

      raise CSVParty::UndefinedRowProcessorError, <<-MSG
Your importer has to define a row processor which specifies what should be done
with each row. It should look something like this:

    rows do |row|
      row.column  # access parsed column values
      row.unparsed.column  # access unparsed column values
    end
      MSG
    end

    def raise_unless_rows_have_been_imported!
      return if rows_have_been_imported

      raise CSVParty::UnimportedRowsError, <<-MSG
The rows in your CSV file have not been imported. You should include a call to
import_rows! at the point in your import block where you want them to be
imported. It should should look something like this:

    import do
      # do stuff before importing rows
      import_rows!
      # do stuff after importing rows
    end
      MSG
    end
  end
end
