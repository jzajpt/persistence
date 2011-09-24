# encoding: utf-8

require 'spec_helper'

describe Persistence::Load do

  class PersistenceTestObject
    attr_accessor :id
  end

  let(:persistence) do
    Class.new do
      extend Persistence::Load
    end
  end

  describe '#load' do

    let(:id)             { BSON::ObjectId.new }
    let(:persisted_hash) { { '_type' => 'PersistenceTestObject', '_id' => id, 'key_a' => 'a', 'key_b' => 'b' } }
    let(:adapter)        { double('Adapter') }

    before do
      adapter.stub(:resource).with(id).and_return(persisted_hash)
      persistence.stub(:adapter).and_return(adapter)
    end

    context 'first run' do

      it 'loads resource hash from adapter' do
        adapter.should_receive(:resource).with(id).and_return(persisted_hash)
        persistence.load(id)
      end

      context 'given valid ID' do

        it 'materializes object based on _type attribute' do
          instance = PersistenceTestObject.new
          PersistenceTestObject.should_receive(:new).and_return(instance)
          persistence.load(id)
        end

        it 'assigns id to materialized object' do
          object = persistence.load(id)
          object.id.should eq(id)
        end

        it 'assigns values from hash to instance variables' do
          object = persistence.load(id)
          object.instance_variable_get(:"@key_a").should eq('a')
          object.instance_variable_get(:"@key_b").should eq('b')
        end

        it 'does not assign @_type' do
          object = persistence.load(id)
          object.instance_variable_get(:"@_type").should be_nil
        end

        it 'does not assign @_id' do
          object = persistence.load(id)
          object.instance_variable_get(:"@_id").should be_nil
        end

        it 'appends object to identity_map' do
          object = persistence.load(id)
          persistence.identity_map[id].should eq(object)
        end

      end

    end

    context 'second run' do

      let(:object) { persistence.load(id) }

      before do
        persistence.identity_map = { id => object }
      end

      it 'does not call persistence' do
        adapter.should_not_receive(:resource)
        persistence.load(id)
      end

      it 'returns object from internal hash' do
        persistence.load(id).should equal(object)
      end

    end

    context 'given invalid ID' do

      it 'returns nil' do
        wrong_id = BSON::ObjectId
        adapter.stub(:resource).with(wrong_id).and_return(nil)
        persistence.load(wrong_id).should be_nil
      end

    end

  end

  describe '#all' do

    let(:ids)              { 6.times.map { BSON::ObjectId.new } }
    let(:persisted_hashes) { 6.times.map { |n| { '_id' => ids[n],
                                                 '_type' => "PersistenceTestObject" } } }
    let(:adapter)          { double('Adapter') }
    let(:instance)         { double("PersistenceTestObject", id: nil, assign: nil, assign_id: nil) }

    before do
      adapter.stub(:resources) { persisted_hashes }
      persistence.stub(:adapter) { adapter }
      PersistenceTestObject.stub(:new) { instance }
    end

    it 'loads resource hash from adapter' do
      adapter.should_receive(:resources) { persisted_hashes }
      persistence.all
    end

    it 'materializes each object' do
      persistence.should_receive(:materialize).exactly(6).times
      persistence.all
    end

  end

  describe '#find' do

  end

end
