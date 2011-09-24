# encoding: utf-8

require 'spec_helper'

describe Persistence::Factory do

  class Book
    attr_accessor :id
    attr_accessor :author_name
    attr_accessor :title
    attr_accessor :published_on
  end

  let(:persistence) { Persistence }

  describe '#new' do

    it 'uses tmp ID to store object in identity map' do
      book = Persistence::Factory.new Book, author_name: 'Fyodor Dostoyevsky'
      Persistence.load(book.id).object_id.should eq(book.object_id)
    end

  end

end

