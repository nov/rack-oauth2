module Rack
  module OAuth2
    class AccessToken
      class Mac < AccessToken
        attr_required :secret, :algorithm

        def protocol_params
          super.merge(
            :secret => self.secret,
            :algorithm => self.algorithm
          )
        end
      end
    end
  end
end