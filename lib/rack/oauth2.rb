module Rack
  module OAuth2
    VERSION = ::File.read(
      ::File.join(::File.dirname(__FILE__), '../../VERSION')
    )
  end
end

require 'rack'
require 'json'
require 'httpclient'
require 'active_support/core_ext'
require 'attr_required'
require 'attr_optional'
require 'rack/oauth2/util'
require 'rack/oauth2/server'
require 'rack/oauth2/client'
require 'rack/oauth2/access_token'