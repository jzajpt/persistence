# encoding: utf-8

require 'spec_helper'

class PersistenceTestObject
  attr_accessor :id
end

describe Persistence::ObjectFactory do
  describe '#materialize' do
    let(:factory) { Persistence::ObjectFactory.new hash }
    let(:id)      { BSON::ObjectId.new }
    let(:hash)    { { _type: 'PersistenceTestObject', _id: id, key_a: 'a', key_b: 'b' } }

    it 'materializes object based on _type attribute' do
      instance = PersistenceTestObject.new
      PersistenceTestObject.should_receive(:new).and_return(instance)
      factory.materialize
    end

    it 'assigns id to materialized object' do
      object = factory.materialize
      object.id.should eq(id)
    end

    it 'assigns @type to materialized object' do
      object = factory.materialize
      object.instance_variable_get(:@type).should eq(object.class.name)
    end

    it 'assigns values from hash to instance variables' do
      object = factory.materialize
      object.instance_variable_get(:"@key_a").should eq('a')
      object.instance_variable_get(:"@key_b").should eq('b')
    end

    it 'does not assign @_type' do
      object = factory.materialize
      object.instance_variable_get(:"@_type").should be_nil
    end

    it 'does not assign @_id' do
      object = factory.materialize
      object.instance_variable_get(:"@_id").should be_nil
    end
  end
end
