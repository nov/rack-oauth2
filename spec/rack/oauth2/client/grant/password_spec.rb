require 'spec_helper.rb'

describe Rack::OAuth2::Client::Grant::Password do
  let(:grant) { Rack::OAuth2::Client::Grant::Password }

  context 'when username is given' do
    let :attributes do
      {:username => 'username'}
    end

    context 'when password is given' do
      let :attributes do
        {:username => 'username', :password => 'password'}
      end
      subject { grant.new attributes }
      its(:to_hash) do
        should == {:grant_type => :password, :username => 'username', :password => 'password'}
      end
    end

    context 'otherwise' do
      it do
        expect { grant.new attributes }.should raise_error AttrRequired::AttrMissing
      end
    end
  end

  context 'otherwise' do
    it do
      expect { grant.new }.should raise_error AttrRequired::AttrMissing
    end
  end
end