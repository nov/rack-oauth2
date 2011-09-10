require 'rack'
require 'json'
require 'httpclient'
require 'logger'
require 'active_support/core_ext'
require 'attr_required'
require 'attr_optional'

module Rack
  module OAuth2
    VERSION = ::File.read(
      ::File.join(::File.dirname(__FILE__), '../../VERSION')
    )

    def self.logger
      @@logger
    end
    def self.logger=(logger)
      @@logger = logger
    end
    self.logger = ::Logger.new(STDOUT)
    self.logger.progname = 'Rack::OAuth2'

    def self.debugging?
      @@debugging
    end
    def self.debugging=(boolean)
      @@debugging = boolean
    end
    def self.debug!
      self.debugging = true
    end
    def self.debug(&block)
      original = self.debugging?
      self.debugging = true
      yield
    ensure
      self.debugging = original
    end
    self.debugging = false
  end
end

require 'rack/oauth2/util'
require 'rack/oauth2/server'
require 'rack/oauth2/client'
require 'rack/oauth2/access_token'
require 'rack/oauth2/debugger'