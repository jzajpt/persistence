# encoding: utf-8

require 'spec_helper'

class CriteriaTestClass
end

describe Persistence::Criteria do

  let(:persistence) do
    Class.new do
      extend Persistence::Criteria
    end
  end

  describe '#select' do

    context 'with hash conditions' do

      let(:iterator) { persistence.select(name: 'Adam') }

      it 'returns Persistence::Iterator' do
        iterator.should be_kind_of(Persistence::Iterator)
      end

      it 'returns iterator with conditions hash' do
        iterator.criteria.should eq(name: 'Adam')
      end

      context 'expanding criteria' do

        before do
          persistence.criteria = { foo: 'bar' }
        end

        let(:iterator) { persistence.select(name: 'Adam') }

        it 'returns Persistence::Iterator' do
          iterator.should be_kind_of(Persistence::Iterator)
        end

        it 'returns iterator with merged conditions hash' do
          iterator.criteria.should eq(foo: 'bar', name: 'Adam')
        end

      end

      context 'ovewriting criteria' do

        before do
          persistence.criteria = { foo: 'oldbar' }
        end

        let(:iterator) { persistence.select(foo: 'newbar') }

        it 'returns Persistence::Iterator' do
          iterator.should be_kind_of(Persistence::Iterator)
        end

        it 'returns iterator with merged conditions hash' do
          iterator.criteria.should eq(foo: 'newbar')
        end

      end

    end

    context 'with class argument' do

      let(:iterator) { persistence.select(CriteriaTestClass) }

      it 'returns Persistence::Iterator' do
        iterator.should be_kind_of(Persistence::Iterator)
      end

      it 'returns iterator with conditions hash - _type' do
        iterator.criteria.should eq(_type: 'CriteriaTestClass')
      end

    end

    context 'with class argument and hash conditions' do

      let(:iterator) { persistence.select(CriteriaTestClass, said: 'ohai') }

      it 'returns Persistence::Iterator' do
        iterator.should be_kind_of(Persistence::Iterator)
      end

      it 'returns iterator with merged conditions' do
        iterator.criteria.should eq(_type: 'CriteriaTestClass', said: 'ohai')
      end

    end

  end

  describe '#method_missing' do

    context 'given snake-cased valid class name' do

      let(:iterator) { persistence.criteria_test_classes }

      it 'returns Persistence::Iterator' do
        iterator.should be_kind_of(Persistence::Iterator)
      end

      it 'adds a condition for _type field from method name' do
        iterator.criteria.should eq(_type: 'CriteriaTestClass')
      end

    end

    context 'given non-existing class name' do

      it 'raises NoMethodError' do
        expect { persistence.invalid_persons }.to raise_error(NoMethodError)
      end

    end

  end

end
