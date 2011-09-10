module Rack
  module OAuth2
    module Debugger
      class RequestFilter
        # Callback called in HTTPClient (before sending a request)
        # request:: HTTP::Message
        def filter_request(request)
          started = "======= [Rack::OAuth2] HTTP REQUEST STARTED ======="
          OAuth2.logger.info [started, request.dump].join("\n")
        end

        # Callback called in HTTPClient (after received a response)
        # request::  HTTP::Message
        # response:: HTTP::Message
        def filter_response(request, response)
          finished = "======= [Rack::OAuth2] HTTP REQUEST FINISHED ======="
          OAuth2.logger.info ['-' * 50, response.dump, finished].join("\n")
        end
      end
    end
  end
end