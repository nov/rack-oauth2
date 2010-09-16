require 'rack'
require 'json'
require 'active_support/core_ext'
require 'rack/oauth2/server'

module Rack
  module OAuth2
    OAUTH_TOKEN = "rack.oauth2.oauth_token"
  end
end