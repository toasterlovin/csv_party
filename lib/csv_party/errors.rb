module CSVParty
  class Error < StandardError
  end

  class UnknownParserError < Error
  end

  class DuplicateColumnError < Error
  end

  class MissingCSVError < Error
  end

  class ReservedColumnNameError < Error
  end

  class MissingColumnError < Error
  end

  class UndefinedRowProcessorError < Error
  end

  class MissingDependencyError < Error
  end

  class UnimportedRowsError < Error
  end

  class NextRowError < Error
  end

  class SkippedRowError < Error
  end

  class AbortedRowError < Error
  end

  class AbortedImportError < Error
  end
end
