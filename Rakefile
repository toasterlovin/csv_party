require 'rake/testtask'

Rake::TestTask.new do |t|
  t.warning = true
  t.libs << 'test'
  t.test_files = FileList['test/*test.rb']
end

desc 'Run tests'
task default: :test
