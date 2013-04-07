Gem::Specification.new do |s|
  s.name = "rack-oauth2"
  s.version = File.read("VERSION")
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["nov matake"]
  s.description = %q{OAuth 2.0 Server & Client Library. Both Bearer and MAC token type are supported.}
  s.summary = %q{OAuth 2.0 Server & Client Library - Both Bearer and MAC token type are supported}
  s.email = "nov@matake.jp"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/nov/rack-oauth2"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.add_runtime_dependency "rack", ">= 1.1"
  s.add_runtime_dependency "multi_json", ">= 1.3.6"
  s.add_runtime_dependency "httpclient", ">= 2.2.0.2"
  s.add_runtime_dependency "activesupport", ">= 2.3"
  s.add_runtime_dependency "attr_required", ">= 0.0.5"
  s.add_development_dependency "rake", ">= 0.8"
  if RUBY_VERSION >= '1.9'
    s.add_development_dependency "cover_me", ">= 1.2.0"
  else
    s.add_development_dependency "rcov", ">= 0.9"
  end
  s.add_development_dependency "rspec", ">= 2"
  s.add_development_dependency "webmock", ">= 1.6.2"
end
