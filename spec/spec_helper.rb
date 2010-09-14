$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rack/oauth2'
require 'spec'
require 'spec/autorun'
require 'rack/mock'

Spec::Runner.configure do |config|
  
end
