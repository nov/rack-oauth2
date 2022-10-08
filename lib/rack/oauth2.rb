require 'rack'
require 'faraday'
require 'faraday/follow_redirects'
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'attr_required'
require 'attr_optional'

module Rack
  module OAuth2
    VERSION = ::File.read(
      ::File.join(::File.dirname(__FILE__), '../../VERSION')
    ).strip

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

    def self.http_client(agent_name = "Rack::OAuth2 (#{VERSION})", &local_http_config)
      Faraday.new(headers: {user_agent: agent_name}) do |faraday|
        faraday.request :url_encoded
        faraday.request :json
        faraday.response :logger, Rack::OAuth2.logger, {bodies: true} if debugging?
        faraday.adapter Faraday.default_adapter
        local_http_config&.call(faraday)
        http_config&.call(faraday)
      end
    end

    def self.http_config(&block)
      @@http_config ||= block
    end

    def self.reset_http_config!
      @@http_config = nil
    end
  end
end

require 'rack/oauth2/urn'
require 'rack/oauth2/util'
require 'rack/oauth2/server'
require 'rack/oauth2/client'
require 'rack/oauth2/access_token'
