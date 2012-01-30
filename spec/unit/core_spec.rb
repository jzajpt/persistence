# encoding: utf-8

require 'spec_helper'

describe Persistence::Core do
  let(:database) { mock "Mongo::Database" }
  let(:mongo_adapter) { mock Persistence::Adapters::MongoDatabaseAdapter, database: database, connect: nil }
  let(:gridfs_adapter) { mock Persistence::Adapters::GridFsAdapter }

  before do
    Persistence::Adapters::MongoDatabaseAdapter.stub(:new).and_return mongo_adapter
    Persistence::Adapters::GridFsAdapter.stub(:new).and_return gridfs_adapter
  end

  describe '#initialize' do
    let(:options) { {} }
    let(:mapper) { Persistence::Core.new(options) }

    it 'creates Mongo adapter' do
      Persistence::Adapters::MongoDatabaseAdapter.should_receive(:new).with(options)
      mapper
    end

    it 'connects Mongo adapter' do
      mongo_adapter.should_receive :connect
      mapper
    end

    it 'creates GridFs adapter' do
      Persistence::Adapters::GridFsAdapter.should_receive(:new).with(database: database)
      mapper
    end
  end

  describe '#register_mapper' do
    let(:klass) { mock "MapperClass", new: nil, :instance= => nil}
    let(:instance) { mock "Mapper" }
    let(:mapper) { Persistence::Core.new }

    before do
      klass.stub(:new).and_return instance
    end

    it 'creates instance of given class and assigns it as instance' do
      klass.should_receive(:new).with mongo_adapter, gridfs_adapter
      klass.should_receive(:instance=).with instance
      mapper.register_mapper :test, klass
    end

    it 'appends new instance to @mappers' do
      mapper_instance = mock "Mapper instance"
      klass.stub(:new).and_return mapper_instance
      mapper.register_mapper :test, klass
      mapper.instance_variable_get(:@mappers)[:test].should eq mapper_instance
    end
  end
end

