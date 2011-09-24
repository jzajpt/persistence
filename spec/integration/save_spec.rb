# encoding: utf-8

require 'spec_helper'

describe Persistence::Save do

  class Book
    attr_accessor :id
    attr_accessor :author_name
    attr_accessor :title
    attr_accessor :released_on
  end

  let(:persistence) { Persistence }

  describe '#save' do

    let(:book_data) { { author_name: 'George Orwell', title: '1987' } }
    let(:book)      { Book.new }
    let(:save_book) { Persistence.save book }

    before do
      book_data.each { |k,v| book.send :"#{k}=", v }
    end

    it "persists new object" do
      expect { save_book }.to change { Persistence.adapter.resources.count }.by(1)
      persisted = Persistence.adapter.resource book.id
      persisted.slice(:author_name, :title).should eq(book_data)
    end

    it "persists hash" do
      expect {
        Persistence.save book_data
      }.to change {
        Persistence.adapter.resources.count
      }.by(1)
    end

    it "persists existing object" do
      save_book
      book.title = 'Animal Farm'
      Persistence.save book
      persisted = Persistence.adapter.resource book.id
      persisted[:title].should eq(book.title)
    end

  end
end

