module CSVParty
  class UnknownParserError < ArgumentError
  end

  class DuplicateColumnError < ArgumentError
  end

  class ReservedColumnNameError < ArgumentError
  end

  class MissingColumnError < RuntimeError
  end

  class UndefinedRowProcessorError < RuntimeError
  end

  class MissingDependencyError < ArgumentError
  end

  class SkippedRowError < RuntimeError
  end

  class AbortedRowError < RuntimeError
  end

  class AbortedImportError < RuntimeError
  end
end
