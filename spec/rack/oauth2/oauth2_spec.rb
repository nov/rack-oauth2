require 'spec_helper'

describe Rack::OAuth2 do
  subject { Rack::OAuth2 }
  after { Rack::OAuth2.debugging = false }

  its(:logger) { should be_a Logger }
  its(:debugging?) { should be_false }

  describe '.debug!' do
    before { Rack::OAuth2.debug! }
    its(:debugging?) { should be_true }
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      Rack::OAuth2.debug do
        Rack::OAuth2.debugging?.should be_true
      end
      Rack::OAuth2.debugging?.should be_false
    end

    it 'should not force disable debugging' do
      Rack::OAuth2.debug!
      Rack::OAuth2.debug do
        Rack::OAuth2.debugging?.should be_true
      end
      Rack::OAuth2.debugging?.should be_true
    end
  end

  # describe '.http_config' do
  #   context 'when request_filter added' do
  #     context 'when "debug!" is called' do
  #       after { Rack::OAuth2.http_config = nil }
  # 
  #       it 'should put Debugger::RequestFilter at last' do
  #         Rack::OAuth2.debug!
  #         Rack::OAuth2.http_config do |config|
  #           config.request_filter << Proc.new {}
  #         end
  #         Rack::OAuth2.http_client.request_filter.last.should be_instance_of Rack::OAuth2::Debugger::RequestFilter
  #       end
  #     end
  #   end
  # end
end