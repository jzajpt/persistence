# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper do
  let(:options) { {} }
  let(:mapper) { Persistence::Mapper.new mongo_adapter, gridfs_adapter }
  let(:database) { mock "Mongo::Database" }
  let(:mongo_adapter) { mock Persistence::Adapters::Mongo, database: database }
  let(:gridfs_adapter) { mock Persistence::Adapters::GridFs }

  describe '#new' do
    let(:collection_adapter) { mock Persistence::Adapters::MongoCollectionAdapter }

    before do
      Persistence::Adapters::MongoCollectionAdapter.stub(:new).and_return collection_adapter
    end

    it 'stores Mongo adapter' do
      mapper
      mapper.database_adapter.should eq mongo_adapter
    end

    it 'stores GridFs adapter' do
      mapper
      mapper.file_adapter.should eq gridfs_adapter
    end

    it 'creates mongo collection adapter' do
      Persistence::Mapper.stub(:name).and_return 'UserMapper'
      Persistence::Adapters::MongoCollectionAdapter.should_receive(:new).with mongo_adapter, 'users'
      mapper
      mapper.collection_adapter.should eq collection_adapter
    end
  end

  describe '#collection_name' do
    it 'figures out name from class name' do
      mapper.class.stub(:name).and_return "UserMapper"
      mapper.collection_name.should eq "users"
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

