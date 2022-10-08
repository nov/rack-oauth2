require 'spec_helper'

describe Rack::OAuth2 do
  subject { Rack::OAuth2 }
  after { Rack::OAuth2.debugging = false }

  its(:logger) { should be_a Logger }
  its(:debugging?) { should == false }

  describe '.debug!' do
    before { Rack::OAuth2.debug! }
    its(:debugging?) { should == true }
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      Rack::OAuth2.debug do
        Rack::OAuth2.debugging?.should == true
      end
      Rack::OAuth2.debugging?.should == false
    end

    it 'should not force disable debugging' do
      Rack::OAuth2.debug!
      Rack::OAuth2.debug do
        Rack::OAuth2.debugging?.should == true
      end
      Rack::OAuth2.debugging?.should == true
    end
  end
end