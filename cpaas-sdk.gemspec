lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cpaas-sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'cpaas-sdk'
  spec.version       = Cpaas::VERSION
  spec.authors       = ['Keepworks']
  spec.email         = ['kandy@keepworks.com']

  spec.summary       = %q{CPaaS Library}
  spec.description   = %q{SDK to build robust real-time communication applications.}
  spec.homepage      = 'https://github.com/Kandy-IO/kandy-cpaas-ruby-sdk'
  spec.license       = 'SEE LICENSE IN LICENSE.md'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.6.2'
  spec.add_development_dependency 'yard', '~> 0.9.20'
  spec.add_development_dependency 'pry', '~> 0.12.2'

  spec.add_dependency 'jwt', '~> 2.2.1'
  spec.add_dependency 'httparty', '~> 0.17'
end
