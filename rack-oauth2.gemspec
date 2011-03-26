Gem::Specification.new do |s|
  s.name = "rack-oauth2"
  s.version = File.read("VERSION")
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["nov matake"]
  s.description = %q{Rack Middleware for OAuth2 server. OAuth2 client library is also included.}
  s.summary = %q{Rack Middleware for OAuth2 server}
  s.email = "nov@matake.jp"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/nov/rack-oauth2"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_runtime_dependency "rack", ">= 1.1"
  s.add_runtime_dependency "json", ">= 1.4.3"
  s.add_runtime_dependency "restclient_with_cert"
  s.add_runtime_dependency "activesupport", ">= 2.3"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "attr_required", ">= 0.0.3"
  s.add_development_dependency "rake", ">= 0.8"
  s.add_development_dependency "rcov", ">= 0.9"
  s.add_development_dependency "rspec", ">= 2"
  s.add_development_dependency "fakeweb", ">= 1.3"
end
