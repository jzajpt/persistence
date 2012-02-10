# encoding: utf-8

require 'spec_helper'

class PersistenceTestObject
  attr_accessor :id
end

describe Persistence::Mapper::Load do
  let(:mapper) do
    Class.new do
      include Persistence::Mapper::Load
      include Persistence::Mapper::Criteria
    end.new
  end

  describe '#find' do
    let(:id)             { BSON::ObjectId.new }
    let(:persisted_hash) { { _type: 'PersistenceTestObject', _id: id, key_a: 'a', key_b: 'b' } }
    let(:adapter)        { double('Adapter') }
    let(:iterator)       { double('Iterator').as_null_object }

    before do
      mapper.stub(:collection_adapter).and_return(adapter)
      mapper.stub(:select).and_return iterator
    end

    it 'selects object with given id' do
      mapper.should_receive(:select).with(_id: id)
      mapper.find id
    end

    it 'returns the first object from iterator' do
      iterator.should_receive(:first).and_return 'obj1'
      mapper.find(id).should eq 'obj1'
    end

    context 'given except option' do
      it 'filters iterator using except' do
        iterator.should_receive(:except).with([:foo, :bar])
        mapper.find(id, except: [:foo, :bar])
      end
    end
  end

  describe '#first' do
    let(:adapter)  { double('Adapter') }
    let(:iterator) { mock "Iterator", first: nil }

    before do
      mapper.stub(:collection_adapter) { adapter }
      Persistence::Mapper::Iterator.stub(:new).and_return iterator
    end

    it "creates new instance of iterator class" do
      Persistence::Mapper::Iterator.should_receive(:new).with adapter
      iterator.should_receive :first
      mapper.first
    end

    it "returns result of first from iterator" do
      first_result = "first result"
      iterator.stub(:first).and_return first_result
      mapper.first.should eq first_result
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
      mapper.stub(:collection_adapter) { adapter }
      PersistenceTestObject.stub(:new).and_return instance
      Persistence::ObjectFactory.stub(:new).and_return object_factory
    end

    it 'loads resource hash from adapter' do
      adapter.should_receive(:resources) { persisted_hashes }
      mapper.all
    end

    it 'materializes each object' do
      Persistence::ObjectFactory.should_receive(:new).exactly(6).times
      object_factory.should_receive(:materialize).exactly(6).times
      mapper.all
    end
  end
end
