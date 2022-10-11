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
    params = options&.[](:params) || {}
    case method
    when :post, :put, :delete
      request[:body] = params
    else
      request[:query] = params
    end
    if options[:request_header]
      request[:headers] = options[:request_header]
    end
    request
  end

  def response_for(response_file, options = {})
    response = {}
    format = options[:format] || :json
    if format == :json
      response[:headers] = {
        'Content-Type': 'application/json'
      }
    end
    response[:body] = File.new(File.join(File.dirname(__FILE__), '../mock_response', "#{response_file}.#{format}"))
    if options[:status]
      response[:status] = options[:status]
    end
    response
  end
end

include WebMockHelper
WebMock.disable_net_connect!