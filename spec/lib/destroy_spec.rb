# encoding: utf-8

require 'spec_helper'

describe Persistence::Destroy do

  let(:persistence) do
    Class.new do
      extend Persistence::Base
      extend Persistence::Destroy
    end
  end

  describe '#destroy' do

    let(:adapter) { double('Adapter') }
    let(:id)      { BSON::ObjectId.new }

    before do
      persistence.stub(:adapter).and_return(adapter)
      adapter.stub(:desroy_resource)
    end

    it "destroys given resource" do
      adapter.should_receive(:destroy_resource).with(id)
      persistence.destroy(id)
    end

  end

end
