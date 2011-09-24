# encoding: utf-8

require 'spec_helper'

describe Persistence::Destroy do

  let(:persistence) do
    Class.new do
      extend Persistence::Base
      extend Persistence::Load
      extend Persistence::Destroy
    end
  end

  describe '#destroy' do

    let(:adapter) { double('Adapter') }
    let(:id)      { BSON::ObjectId.new }

    before do
      persistence.identity_map[id] = {}
      persistence.stub(:adapter).and_return(adapter)
      adapter.stub(:destroy_resource)
    end

    it "destroys given resource" do
      adapter.should_receive(:destroy_resource).with(id)
      persistence.destroy(id)
    end

    context 'given valid ID' do

      before do
        adapter.stub(:destroy_resource).and_return(id)
      end

      it "removes object from identity map" do
        persistence.destroy(id)
        persistence.identity_map.should_not have_key(id)
      end

      it 'returns destroyed object ID' do
        persistence.destroy(id).should eq(id)
      end

    end

    context 'given invalid ID' do

      it 'does not remove anything from identity map' do
        persistence.destroy(id)
        persistence.identity_map.should_not_receive(:delete)
      end

      it 'returns nil' do
        persistence.destroy(id).should eq(nil)
      end

    end

  end

end
