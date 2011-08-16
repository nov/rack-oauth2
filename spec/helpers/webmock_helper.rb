require 'webmock/rspec'

module WebMockHelper
  def mock_response(method, endpoint, response_file, options = {})
    stub_request(method, endpoint).with(
      request_for(method, options)
    ).to_return(
      response_for(response_file, options)
    )
  end

  private

  def request_for(method, options = {})
    request = {}
    if options[:params]
      case method
      when :post, :put
        request[:body] = options[:params]
      else
        request[:query] = options[:params]
      end
    end
    request
  end

  def response_for(response_file, options = {})
    response = {}
    response[:body] = File.new(File.join(File.dirname(__FILE__), '../mock_response', response_file))
    if options[:status]
      response[:status] = options[:status]
    end
    response
  end
end

include WebMockHelper
WebMock.disable_net_connect!