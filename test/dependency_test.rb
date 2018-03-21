require 'test_helper'

class DependencyTest < Minitest::Test
  def test_provides_access_to_external_dependencies
    dependency = SecureRandom.random_number
    importer = ExternalDependencyImporter.new(
      'test/csv/external_dependency.csv',
      dependency: dependency
    )
    importer.result = {}
    importer.import!

    assert_equal dependency, importer.result[:column_dep]
    assert_equal dependency, importer.result[:rows_dep]
    assert_equal dependency, importer.result[:import_dep]
    assert_equal dependency, importer.result[:errors_dep]
  end

  def test_missing_dependency
    importer = ExternalDependencyImporter.new(
      'test/csv/external_dependency.csv'
    )
    importer.result = {}

    assert_raises CSVParty::MissingDependencyError do
      importer.import!
    end

    importer.dependency = SecureRandom.random_number
    importer.import!
  end
end
