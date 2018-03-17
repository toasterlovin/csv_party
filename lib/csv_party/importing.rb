module CSVParty
  module Importing
    attr_accessor :columns, :row_importer, :importer,
                  :error_processor, :dependencies

    attr_reader :imported_rows, :skipped_rows, :aborted_rows,
                :abort_message

    def import!
      if importer
        instance_exec(&importer)
      else
        import_rows!
      end
    rescue AbortedImportError => error
      @aborted = true
      @abort_message = error.message
    end

    def import_rows!
      loop do
        begin
          row = @csv.shift
          break unless row
          import_row!(row)
          imported_rows << @csv.lineno
        rescue SkippedRowError
          skipped_rows << @csv.lineno
          next
        rescue AbortedImportError => error
          raise AbortedImportError, error.message
        rescue StandardError => error
          process_error(error, @csv.lineno + 1)
          aborted_rows << @csv.lineno
          next
        end
      end
    end

    def aborted?
      @aborted
    end

    private

    def import_row!(row)
      parsed_row = parse_row(row)
      instance_exec(parsed_row, &row_importer)
    end

    def parse_row(row)
      unparsed_row = OpenStruct.new
      columns.each do |column, options|
        header = options[:header]
        unparsed_row[column] = row[header]
      end

      parsed_row = OpenStruct.new
      columns.each do |column, options|
        value = row[options[:header]]
        parsed_row[column] = parse_column(
          value,
          options[:parser],
          options[:format],
          options[:blanks_as_nil]
        )
      end

      parsed_row[:unparsed] = unparsed_row
      parsed_row[:csv_string] = row.to_csv

      return parsed_row
    end

    def parse_column(value, parser, format, blanks_as_nil)
      if blanks_as_nil && is_blank?(value)
        nil
      elsif parser.is_a? Symbol
        if format.nil?
          send(parser, value)
        else
          send(parser, value, format)
        end
      else
        instance_exec(value, &parser)
      end
    end

    def process_error(error, line_number)
      instance_exec(error, line_number, &error_processor)
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

    def is_blank?(value)
      value.nil? || value.strip.empty?
    end

    module ClassMethods
    end
  end
end
