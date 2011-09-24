# encoding: utf-8

require 'spec_helper'

describe Persistence::Factory do

  class Book
  end

  describe '#new' do

    context 'given class' do
      it 'creates object of given class' do
        object = Persistence::Factory.new Book
        object.should be_kind_of(Book)
      end

      it 'stores object in identity map' do
        Persistence.identity_map = {}
        object = Persistence::Factory.new Book
        Persistence.identity_map.size.should eq(1)
      end
    end

    context 'given class name in string' do
      it 'creates object of given class' do
        object = Persistence::Factory.new 'Book'
        object.should be_kind_of(Book)
      end
    end

    context 'given class and attributes' do
      it 'creates object with given attributes' do
        object = Persistence::Factory.new 'Book', title: 'Animal Farm'
        object.should be_kind_of(Book)
        object.title.should eq('Animal Farm')
      end
    end

    context 'given class and attributes with id' do
      it 'stores object in identity map[' do
        id = BSON::ObjectId.new
        object = Persistence::Factory.new 'Book', id: id, title: 'Animal Farm'
        Persistence.identity_map[id].should eq(object)
      end
    end

  end

end

