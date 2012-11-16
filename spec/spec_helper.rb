if RUBY_VERSION >= '1.9'
  require 'cover_me'
end

require 'rspec'
require 'rack/oauth2'
require 'helpers/time'
require 'helpers/webmock_helper'

def simple_app
  lambda do |env|
    [ 200, {'Content-Type' => 'text/plain'}, ["HELLO"] ]
  end
end

RSpec.configure do |config|
  config.color_enabled = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
