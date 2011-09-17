# encoding: utf-8

require 'spec_helper'

describe Persistence::Destroy do

  let(:persistence_class) do
    Class.new do
      include Persistence::Base
      include Persistence::Destroy
    end
  end
  let(:persistence) { persistence_class.new }

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
