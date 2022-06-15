Gem::Specification.new do |s|
  s.name        = 'csv_party'
  s.version     = '1.0.0.rc5'
  s.date        = '2017-06-05'
  s.summary     = 'CSV Party'
  s.description = 'A gem for making CSV imports a little more fun.'
  s.authors     = ['Rico Jones']
  s.email       = 'rico@toasterlovin.com'
  s.files       = Dir.glob('lib/**/*') + %w[LICENSE.md README.md ROADMAP.md]
  s.homepage    = 'https://github.com/toasterlovin/csv_party'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.6'
end
