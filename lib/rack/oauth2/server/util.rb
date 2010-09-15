module Rack
  module OAuth2
    module Server
      module Util
        class << self
          def parse_uri(uri)
            case uri
            when URI::Generic
              uri
            when String
              URI.parse(uri)
            else
              raise "Invalid format of URI is given."
            end
          end
        end
      end
    end
  end
end