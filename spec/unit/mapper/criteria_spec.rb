# encoding: utf-8

require 'spec_helper'

class CriteriaTestClass
end

describe Persistence::Mapper::Criteria do

  let(:persistence) do
    Class.new do
      extend Persistence::Mapper::Criteria
      cattr_accessor :collection_adapter
    end
  end

  describe '#select' do

    context 'with hash conditions' do

      let(:iterator) { persistence.select(name: 'Adam') }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with conditions hash' do
        iterator.criteria.should eq(name: 'Adam')
      end

      context 'expanding criteria' do

        before do
          persistence.criteria = { foo: 'bar' }
        end

        let(:iterator) { persistence.select(name: 'Adam') }

        it 'returns Persistence::Mapper::Iterator' do
          iterator.should be_kind_of(Persistence::Mapper::Iterator)
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

        it 'returns Persistence::Mapper::Iterator' do
          iterator.should be_kind_of(Persistence::Mapper::Iterator)
        end

        it 'returns iterator with merged conditions hash' do
          iterator.criteria.should eq(foo: 'newbar')
        end

      end

    end

    context 'with class argument' do

      let(:iterator) { persistence.select(CriteriaTestClass) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with conditions hash - _type' do
        iterator.criteria.should eq(_type: 'CriteriaTestClass')
      end

    end

    context 'with class argument and hash conditions' do

      let(:iterator) { persistence.select(CriteriaTestClass, said: 'ohai') }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions' do
        iterator.criteria.should eq(_type: 'CriteriaTestClass', said: 'ohai')
      end

    end

  end

  describe '#only' do
    context 'setting new options' do
      let(:iterator) { persistence.only(:newfoo, :oldbar) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq fields: { newfoo: 1, oldbar: 1}
      end
    end

    context 'expanding options' do
      before do
        persistence.options = { fields: { foo: 1, bar: 1 } }
      end

      let(:iterator) { persistence.only([:ohai]) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq fields: { foo: 1, bar: 1, ohai: 1 }
      end
    end
  end

  describe '#except' do
    context 'setting new options' do
      let(:iterator) { persistence.except(:newfoo, :oldbar) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq fields: { newfoo: 0, oldbar: 0 }
      end
    end

    context 'expanding options' do
      before do
        persistence.options = { fields: {foo: 0, bar: 0} }
      end

      let(:iterator) { persistence.except([:ohai]) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq fields: { foo: 0, bar: 0, ohai: 0 }
      end
    end
  end

  describe '#sort' do
    context 'setting new options' do
      let(:iterator) { persistence.sort(['newfoo', :asc]) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq sort: [['newfoo', :asc]]
      end
    end

    context 'expanding options' do
      before do
        persistence.options = { sort: [['foo', :asc]] }
      end

      let(:iterator) { persistence.sort(['bar', :desc]) }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
      end

      it 'returns iterator with merged conditions hash' do
        iterator.options.should eq sort: [['foo', :asc], ['bar', :desc]]
      end
    end
  end

  describe '#method_missing' do

    context 'given snake-cased valid class name' do

      let(:iterator) { persistence.criteria_test_classes }

      it 'returns Persistence::Mapper::Iterator' do
        iterator.should be_kind_of(Persistence::Mapper::Iterator)
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

