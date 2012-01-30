# encoding: utf-8

require 'spec_helper'

class PersistenceTestObject
  attr_accessor :id
end

describe Persistence::Mapper::Load do

  let(:test_class) do
    Class.new do
      include Persistence::Mapper::Load
      include Persistence::Mapper::Criteria
    end
  end
  let(:persistence) { test_class.new }

  describe '#find' do
    let(:id)             { BSON::ObjectId.new }
    let(:persisted_hash) { { _type: 'PersistenceTestObject', _id: id, key_a: 'a', key_b: 'b' } }
    let(:adapter)        { double('Adapter') }
    let(:iterator)       { double('Iterator').as_null_object }

    before do
      persistence.stub(:collection_adapter).and_return(adapter)
      persistence.stub(:select).and_return iterator
    end

    it 'selects object with given id' do
      persistence.should_receive(:select).with(_id: id)
      persistence.find id
    end

    it 'returns the first object from iterator' do
      iterator.should_receive(:first).and_return 'obj1'
      persistence.find(id).should eq 'obj1'
    end

    context 'given except option' do

      it 'filters iterator using except' do
        iterator.should_receive(:except).with([:foo, :bar])
        persistence.find(id, except: [:foo, :bar])
      end

    end
  end

  describe '#all' do
    let(:ids)              { 6.times.map { BSON::ObjectId.new } }
    let(:persisted_hashes) { 6.times.map { { _type: "PersistenceTestObject" } } }
    let(:adapter)          { double('Adapter') }
    let(:instance)         { double("PersistenceTestObject", assign: nil, assign_id: nil) }
    let(:object_factory)   { mock Persistence::ObjectFactory, materialize: nil }

    before do
      adapter.stub(:resources) { persisted_hashes }
      persistence.stub(:collection_adapter) { adapter }
      PersistenceTestObject.stub(:new).and_return instance
      Persistence::ObjectFactory.stub(:new).and_return object_factory
    end

    it 'loads resource hash from adapter' do
      adapter.should_receive(:resources) { persisted_hashes }
      persistence.all
    end

    it 'materializes each object' do
      Persistence::ObjectFactory.should_receive(:new).exactly(6).times
      object_factory.should_receive(:materialize).exactly(6).times
      persistence.all
    end
  end
end
