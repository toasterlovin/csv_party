require 'test_helper'

class DependencyTest < Minitest::Test
  class ExternalDependencyImporter < CSVParty::Importer
    depends_on :dependency

    column :first, header: 'First'
    column :second, header: 'Second' do |value|
      # ensures errors block gets run at least once
      raise if value.eql?('0')

      result[:column_dep] = dependency
      value
    end

    rows do
      result[:rows_dep] = dependency
    end

    import do
      result[:import_dep] = dependency
      import_rows!
    end

    errors do
      result[:errors_dep] = dependency
    end
  end

  def setup
    @csv = <<-CSV
First,Second
1,1
1,0
    CSV
  end

  def test_provides_access_to_external_dependencies
    dependency = SecureRandom.random_number
    importer = ExternalDependencyImporter.new(
      content: @csv,
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
    importer = ExternalDependencyImporter.new(content: @csv)
    importer.result = {}

    assert_raises CSVParty::MissingDependencyError do
      importer.import!
    end

    importer.dependency = SecureRandom.random_number
    importer.import!
  end
end
