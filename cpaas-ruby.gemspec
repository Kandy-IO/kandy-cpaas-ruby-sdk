
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cpaas/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpaas-ruby'
  spec.version       = Cpaas::VERSION
  spec.authors       = ['Ashit Rath']
  spec.email         = ['ashit@keepworks.com']

  spec.summary       = %q{Kandy CPaaS Library}
  spec.description   = %q{Build robust real-time communication applications.}
  spec.homepage      = 'TODO: Homepage url'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.6.2'
  spec.add_development_dependency 'yard', '~> 0.9.20'
  spec.add_development_dependency 'pry', '~> 0.12.2'

  spec.add_dependency 'jwt', '~> 2.2.1'
  spec.add_dependency 'httparty', '~> 0.17'
end
