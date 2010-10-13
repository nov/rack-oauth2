require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'rack-oauth2'
    gem.summary = %Q{Rack Middleware for OAuth2 Server}
    gem.description = %Q{Rack Middleware for OAuth2. Currently support only Server/Provider, not Client/Consumer.}
    gem.email = 'nov@matake.jp'
    gem.homepage = 'http://github.com/nov/rack-oauth2'
    gem.authors = ['nov matake']
    gem.add_dependency 'json'
    gem.add_dependency 'activesupport'
    gem.add_development_dependency 'rspec', '>= 2.0.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = ['--exclude spec,gems']
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'rack-oauth2 #{version}'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
