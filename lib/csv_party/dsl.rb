require 'csv_party/configuration'

module CSVParty
  module DSL
    def column(column, options = {}, &block)
      config.add_column(column, options, &block)
    end

    def rows(&block)
      config.row_importer = block
    end

    def import(&block)
      config.file_importer = block
    end

    def errors(setting = nil, &block)
      config.error_handler = setting || block
    end

    def skipped_rows(setting = nil, &block)
      config.skipped_row_handler = setting || block
    end

    def aborted_rows(setting = nil, &block)
      config.aborted_row_handler = setting || block
    end

    def depends_on(*args)
      config.add_dependency(*args)
      args.each do |arg|
        attr_accessor arg
      end
    end

    def config
      @config ||= Configuration.new
    end
  end
end
