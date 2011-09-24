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

  end

end

