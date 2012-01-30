# encoding: utf-8

require 'spec_helper'

describe Persistence::Adapters::MongoCollectionAdapter do

  let(:options)            { { host: 'localhost', database_name: 'persistence_test' } }
  let(:database_adapter)   { Persistence::Adapters::MongoDatabaseAdapter.new options }
  let(:collection_adapter) { Persistence::Adapters::MongoCollectionAdapter.new database_adapter, 'test_coll' }
  let(:db)                 { database_adapter.database }
  let(:coll)               { collection_adapter.collection }

  before do
    database_adapter.connect
  end

  describe "#resource" do
    context "with existing ID" do

      let(:id) { coll.insert(_type: 'Richtext') }

      it "returns the hash of object with given id" do
        hash = collection_adapter.resource(id)
        hash[:_type].should eq('Richtext')
        hash[:_id].should eq(id)
      end

      it "doesn't mind string typed ID" do
        hash = collection_adapter.resource("#{id}")
        hash[:_id].should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        collection_adapter.resource(BSON::ObjectId('4e65c366aabc60673c000001')).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          collection_adapter.resource('an-invalid-id')
        }.should raise_exception
      end

    end
  end

  describe "#resources" do
    before do
      coll.remove
      4.times { |i| coll.insert(type: 'Richtext') }
    end

    it "returns an array with hashes of all objects" do
      array = collection_adapter.resources
      array.should be_kind_of(Array)
      array.size.should eq(4)
    end
  end

  describe "#insert_resource" do
    let(:hash) { { foo: 'bar', say: 'ohai' } }

    it "returns id assigned" do
      new_id = collection_adapter.insert_resource(hash)
      new_id.should be_kind_of(BSON::ObjectId)
    end

    it "persists a document" do
      -> {
        collection_adapter.insert_resource(hash)
      }.should change(coll, :count).by(1)
    end
  end

  describe "#replace_resource" do
    let(:new_hash) { { foo: 'bar', say: 'ohai' } }

    context "with existing ID" do

      let(:id) { coll.insert(_type: 'Richtext') }

      it "does not create a new persisted object" do
        id
        -> {
          collection_adapter.replace_resource(id, new_hash)
        }.should_not change(coll, :count)
      end

      it "replaces persisted hash with a new one" do
        collection_adapter.replace_resource(id, new_hash)
        expected_hash = new_hash.merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "doesn't mind string typed ID" do
        collection_adapter.replace_resource("#{id}", new_hash)
        expected_hash = new_hash.merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "returns ID of updated document" do
        collection_adapter.replace_resource(id, new_hash).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        collection_adapter.replace_resource(BSON::ObjectId('4e65c366aabc60673c000001'), new_hash).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          collection_adapter.replace_resource('an-invalid-id', new_hash)
        }.should raise_exception
      end

    end
  end


  describe "#update_resource" do
    let(:old_hash) { { _type: 'Richtext' } }
    let(:new_hash) { { foo: 'bar', say: 'ohai' } }

    context "with existing ID" do

      let(:id) { coll.insert(old_hash) }

      it "does not create a new persisted object" do
        id
        -> {
          collection_adapter.update_resource(id, new_hash)
        }.should_not change(coll, :count)
      end

      it "replaces persisted hash with a new one" do
        collection_adapter.update_resource(id, new_hash)
        expected_hash = old_hash.merge(new_hash).merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "doesn't mind string typed ID" do
        collection_adapter.update_resource("#{id}", new_hash)
        expected_hash = old_hash.merge(new_hash).merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "returns ID of updated document" do
        collection_adapter.update_resource(id, new_hash).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        collection_adapter.update_resource(BSON::ObjectId('4e65c366aabc60673c000001'), new_hash).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          collection_adapter.update_resource('an-invalid-id', new_hash)
        }.should raise_exception
      end

    end
  end

  describe "#destroy_resource" do
    context "with existing ID" do

      let(:id) { coll.insert(_type: 'Richtext') }

      it "removes persisted hash" do
        id
        -> {
          collection_adapter.destroy_resource(id)
        }.should change(coll, :count).by(-1)
      end

      it "doesn't mind string typed ID" do
        id
        -> {
          collection_adapter.destroy_resource("#{id}")
        }.should change(coll, :count).by(-1)
      end

      it "returns id of removed hash" do
        id
        collection_adapter.destroy_resource(id).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        collection_adapter.destroy_resource(BSON::ObjectId('4e65c366aabc60673c000001')).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          collection_adapter.destroy_resource('an-invalid-id')
        }.should raise_exception
      end

    end
  end

  describe '#find' do

    before do
      4.times { |i| coll.insert(type: 'Richtext') }
    end

    context 'given _id attribute with string ID in criteria hash' do
      let(:id) { coll.insert(_type: 'Richtext') }

      it 'converts _id to BSON ObjectId' do
        result = collection_adapter.find _id: id.to_s
        result.should_not be_empty
      end
    end

    context 'given valid criteria' do
      it 'returns first matched document' do
        collection_adapter.find(type: 'Richtext').should_not be_empty
      end
    end

    context 'given invalid criteria' do
      it 'returns nil' do
        collection_adapter.find(bull: 'shit').should eq []
      end
    end
  end

  describe '#find_one' do
    before do
      4.times { |i| coll.insert(type: 'Richtext') }
    end

    context 'given _id attribute with string ID in criteria hash' do
      let(:id) { coll.insert(_type: 'Richtext') }

      it 'converts _id to BSON ObjectId' do
        result = collection_adapter.find_one _id: id.to_s
        result.should_not be_nil
      end
    end

    context 'given valid criteria' do
      it 'returns first matched document' do
        collection_adapter.find_one(type: 'Richtext').should_not be_nil
      end
    end

    context 'given invalid criteria' do
      it 'returns nil' do
        collection_adapter.find_one(bull: 'shit').should be_nil
      end
    end
  end
end
