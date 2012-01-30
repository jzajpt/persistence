# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper do
  describe '#new' do
    let(:options) { {} }
    let(:mapper) { Persistence::Mapper.new mongo_adapter, gridfs_adapter }
    let(:database) { mock "Mongo::Database" }
    let(:mongo_adapter) { mock Persistence::Adapters::Mongo, database: database }
    let(:gridfs_adapter) { mock Persistence::Adapters::GridFs }

    before do
      Persistence::Adapters::Mongo.stub(:new).and_return mongo_adapter
      Persistence::Adapters::GridFs.stub(:new).and_return gridfs_adapter
    end

    it 'creates Mongo adapter' do
      mapper
      mapper.adapter.should eq mongo_adapter
    end

    it 'creates GridFs adapter' do
      mapper
      mapper.file_adapter.should eq gridfs_adapter
    end
  end

  describe 'class proxy to singleton instance' do
    let(:instance) { mock "Instance", test_call: nil }

    before do
      Persistence::Mapper.instance = instance
    end

    it 'proxies all calls to instance' do
      instance.should_receive(:test_call).with 1, 2, 3
      Persistence::Mapper.test_call 1, 2, 3
    end

    it 'correctly responds to respond_to?' do
      Persistence::Mapper.should respond_to(:test_call)
    end
  end
end

