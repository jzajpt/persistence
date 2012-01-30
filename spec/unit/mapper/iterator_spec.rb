# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper::Iterator do

  let(:adapter) { mock "Adapter" }
  let(:iterator) { Persistence::Mapper::Iterator.new adapter }

  it 'should include Enumerable module' do
    Persistence::Mapper::Iterator.included_modules.should include(Enumerable)
  end

  describe 'Iterator methods' do

    it 'responds to select from Persistence::Mapper::Iterator' do
      iterator.should respond_to(:select)
    end

  end

  describe '#initialize' do

    it 'stores first argument as criteria' do
      hash = { foo: 'bar' }
      iterator = Persistence::Mapper::Iterator.new(adapter, hash)
      iterator.criteria.should eq(hash)
    end

    it 'stores second argument as options' do
      hash = { foo: 'bar' }
      iterator = Persistence::Mapper::Iterator.new(adapter, {}, hash)
      iterator.options.should eq(hash)
    end

  end

  describe '#each' do

    let(:resources) { [ { _id: BSON::ObjectId.new },
                        { _id: BSON::ObjectId.new },
                        { _id: BSON::ObjectId.new } ] }

    before do
      iterator.stub(:to_a).and_return(resources)
    end

    it 'calls given block with each object' do
      block = Proc.new {}
      block.should_receive(:call).exactly(3).times
      iterator.each(&block).to_a.should eq(resources)
    end

  end

  describe '#all' do
    it 'returns receiver' do
      iterator.all.should eq(iterator)
    end

  end

  describe '#to_a' do
    let(:adapter)        { mock "Adapter", find: nil }
    let(:object_factory) { mock Persistence::ObjectFactory, materialize: nil }

    before do
      Persistence::ObjectFactory.stub(:new).and_return object_factory
      iterator.stub(:adapter).and_return adapter
    end

    context 'with criteria defined' do

      let(:criteria)  { { foo: 'bar' } }
      let(:resources) { [ { _id: BSON::ObjectId.new },
                          { _id: BSON::ObjectId.new } ] }

      before do
        iterator.criteria = hash
        adapter.stub(:find).and_return(resources)
      end

      it 'calls #find with criteria on adapter' do
        adapter.should_receive(:find).with(hash, {})
        iterator.to_a
      end

      it 'materializes each result from #find' do
        Persistence::ObjectFactory.should_receive(:new).with(resources[0]).ordered
        Persistence::ObjectFactory.should_receive(:new).with(resources[1]).ordered
        iterator.to_a
      end

    end

    context 'with options defined - with fields set without _type' do

      let(:options) { { fields: { a: 1, b: 1 } } }

      before do
        iterator.options = options
      end

      it 'calls #find with _type field appended' do
        safe_options = { fields: { a: 1, b: 1, _type: 1 } }
        adapter.should_receive(:find).with({}, safe_options).and_return []
        iterator.to_a
      end

    end

    context 'with options defined' do

      let(:options) { { foo: 'bar' } }

      before do
        iterator.options = options
      end

      it 'calls #find with empty hash conditions but with options' do
        adapter.should_receive(:find).with({}, options).and_return []
        iterator.to_a
      end

    end

    context 'without criteria or options defined' do

      it 'calls #find with empty hash on adapter' do
        adapter.should_receive(:find).with({}, {}).and_return []
        iterator.to_a
      end

    end

  end

  describe '#first' do
    let(:adapter)   { mock "Adapter", find: nil }
    let(:resource) { {} }
    let(:criteria) { { foo: 'bar' } }
    let(:options) { { foo: 'bar' } }
    let(:object_factory) { mock Persistence::ObjectFactory, materialize: nil }

    before do
      Persistence::ObjectFactory.stub(:new).and_return object_factory
      iterator.stub(:adapter).and_return adapter
      adapter.stub(:find_one).and_return resource
      iterator.criteria = criteria
      iterator.options = options
    end

    it 'loads resource from adapter' do
      adapter.should_receive(:find_one).with(criteria, options)
      iterator.first
    end

    it 'adds _type to fields options' do
      options[:fields] = { foo: 1 }
      expected_options = { foo: 'bar', fields: { foo: 1, _type: 1 } }
      adapter.should_receive(:find_one).with(criteria, expected_options)
      iterator.first
    end

    it 'materializes hash from adapter' do
      Persistence::ObjectFactory.should_receive(:new).with resource
      object_factory.should_receive :materialize
      iterator.first
    end

  end

  describe '#count' do
    it 'returns #to_a size' do
      iterator.stub(:to_a).and_return([1,2,3,4])
      iterator.count.should eq(4)
    end
  end
end

