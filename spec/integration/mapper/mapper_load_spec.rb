# encoding: utf-8

require "spec_helper"

class TestObject
  attr_accessor :name
end

class TestObjectMapper < Persistence::Mapper; end

describe "loading objects from Mapper" do
  let(:config_hash) { { host: 'localhost', database_name: 'persistence_test' } }
  let(:persistence) { Persistence::Core.new(config_hash) }
  let(:collection) { TestObjectMapper.collection_adapter.collection }

  before do
    persistence.register_mapper :test_objects, TestObjectMapper
    collection.drop
    5.times { |i| collection.insert _type: 'TestObject', name: "ohai-#{i}" }
  end

  describe "#first" do
    it "returns the first document from collection" do
      doc = TestObjectMapper.first
      doc.should_not be_nil
      doc.name.should eq "ohai-0"
    end
  end

  describe "#all" do
    it "returns all the objects from the collection" do
      docs = TestObjectMapper.all
      docs.count.should eq 5
    end
  end
end
