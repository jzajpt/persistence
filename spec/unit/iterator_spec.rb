# encoding: utf-8

require 'spec_helper'

describe Persistence::Iterator do

  let(:iterator) { Persistence::Iterator.new }

  it 'should include Enumerable module' do
    Persistence::Iterator.included_modules.should include(Enumerable)
  end

  describe 'Iterator methods' do

    it 'responds to select from Persistence::Iterator' do
      iterator.should respond_to(:select)
    end

  end

  describe '#initialize' do

    it 'stores first argument as criteria' do
      hash = { foo: 'bar' }
      iterator = Persistence::Iterator.new(hash)
      iterator.criteria.should eq(hash)
    end

  end

  describe '#each' do

    let(:objects) { ['foo1', 'foo2', 'foo3'] }

    before do
      Persistence.adapter.stub(:find).and_return(objects)
    end

    it 'calls given block with each object' do
      block = Proc.new {}
      block.should_receive(:call).exactly(3).times
      iterator.each(&block).to_a.should eq(objects)
    end

  end

  describe '#all' do

    it 'returns receiver' do
      iterator.all.should eq(iterator)
    end

  end

  describe '#to_a' do

    context 'with criteria defined' do

      let(:criteria) { { foo: 'bar' } }

      before do
        iterator.criteria = hash
        Persistence.adapter.stub(:find)
      end

      it 'calls #find with criteria on adapter' do
        Persistence.adapter.should_receive(:find).with(hash)
        iterator.to_a
      end

      it 'returns result from #find' do
        Persistence.adapter.stub(:find).and_return(:ohai)
        iterator.to_a.should eq(:ohai)
      end

    end

    context 'without criteria defined' do

      before do
        Persistence.adapter.stub(:find)
      end

      it 'calls #find with empty hash on adapter' do
        Persistence.adapter.should_receive(:find).with({})
        iterator.to_a
      end

    end

  end

  describe '#first' do

    it 'returns first object from #to_a' do
      iterator.stub(:to_a).and_return([1,2,3])
      iterator.first.should eq(1)
    end

  end

  describe '#last' do

    it 'returns last object from #to_a' do
      iterator.stub(:to_a).and_return([1,2,3])
      iterator.last.should eq(3)
    end

  end

  describe '#count' do

    it 'returns #to_a size' do
      iterator.stub(:to_a).and_return([1,2,3,4])
      iterator.count.should eq(4)
    end

  end

end

