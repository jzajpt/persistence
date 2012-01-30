# encoding: utf-8

require 'spec_helper'

describe Persistence::Adapters::Mongo do

  let(:adapter)     { Persistence::Adapters::Mongo.new host: 'localhost',
                       database: 'persistence_test', collection: 'persistence_test' }
  let(:db)          { adapter.database }
  let(:coll)        { adapter.collection }

  describe "#resource" do
    context "with existing ID" do

      let(:id) { coll.insert(_type: 'Richtext') }

      it "returns the hash of object with given id" do
        hash = adapter.resource(id)
        hash[:_type].should eq('Richtext')
        hash[:_id].should eq(id)
      end

      it "doesn't mind string typed ID" do
        hash = adapter.resource("#{id}")
        hash[:_id].should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        adapter.resource(BSON::ObjectId('4e65c366aabc60673c000001')).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          adapter.resource('an-invalid-id')
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
      array = adapter.resources
      array.should be_kind_of(Array)
      array.size.should eq(4)
    end
  end

  describe "#insert_resource" do
    let(:hash) { { foo: 'bar', say: 'ohai' } }

    it "returns id assigned" do
      new_id = adapter.insert_resource(hash)
      new_id.should be_kind_of(BSON::ObjectId)
    end

    it "persists a document" do
      -> {
        adapter.insert_resource(hash)
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
          adapter.replace_resource(id, new_hash)
        }.should_not change(coll, :count)
      end

      it "replaces persisted hash with a new one" do
        adapter.replace_resource(id, new_hash)
        expected_hash = new_hash.merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "doesn't mind string typed ID" do
        adapter.replace_resource("#{id}", new_hash)
        expected_hash = new_hash.merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "returns ID of updated document" do
        adapter.replace_resource(id, new_hash).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        adapter.replace_resource(BSON::ObjectId('4e65c366aabc60673c000001'), new_hash).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          adapter.replace_resource('an-invalid-id', new_hash)
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
          adapter.update_resource(id, new_hash)
        }.should_not change(coll, :count)
      end

      it "replaces persisted hash with a new one" do
        adapter.update_resource(id, new_hash)
        expected_hash = old_hash.merge(new_hash).merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "doesn't mind string typed ID" do
        adapter.update_resource("#{id}", new_hash)
        expected_hash = old_hash.merge(new_hash).merge(_id: id).stringify_keys
        coll.find(_id: id).first.should eq(expected_hash)
      end

      it "returns ID of updated document" do
        adapter.update_resource(id, new_hash).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        adapter.update_resource(BSON::ObjectId('4e65c366aabc60673c000001'), new_hash).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          adapter.update_resource('an-invalid-id', new_hash)
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
          adapter.destroy_resource(id)
        }.should change(coll, :count).by(-1)
      end

      it "doesn't mind string typed ID" do
        id
        -> {
          adapter.destroy_resource("#{id}")
        }.should change(coll, :count).by(-1)
      end

      it "returns id of removed hash" do
        id
        adapter.destroy_resource(id).should eq(id)
      end

    end

    context "with non-existing ID" do

      it "returns nil" do
        adapter.destroy_resource(BSON::ObjectId('4e65c366aabc60673c000001')).should be_nil
      end

    end

    context "with invalid ID" do

      it "returns nil" do
        -> {
          adapter.destroy_resource('an-invalid-id')
        }.should raise_exception
      end

    end
  end

  describe '#find' do
    let(:coll) { adapter.collection }

    before do
      4.times { |i| coll.insert(type: 'Richtext') }
    end

    context 'given _id attribute with string ID in criteria hash' do
      let(:id) { coll.insert(_type: 'Richtext') }

      it 'converts _id to BSON ObjectId' do
        result = adapter.find _id: id.to_s
        result.should_not be_empty
      end
    end

    context 'given valid criteria' do
      it 'returns first matched document' do
        adapter.find(type: 'Richtext').should_not be_empty
      end
    end

    context 'given invalid criteria' do
      it 'returns nil' do
        adapter.find(bull: 'shit').should eq []
      end
    end
  end

  describe '#find_one' do
    let(:coll) { adapter.collection }

    before do
      4.times { |i| coll.insert(type: 'Richtext') }
    end

    context 'given _id attribute with string ID in criteria hash' do
      let(:id) { coll.insert(_type: 'Richtext') }

      it 'converts _id to BSON ObjectId' do
        result = adapter.find_one _id: id.to_s
        result.should_not be_nil
      end
    end

    context 'given valid criteria' do
      it 'returns first matched document' do
        adapter.find_one(type: 'Richtext').should_not be_nil
      end
    end

    context 'given invalid criteria' do
      it 'returns nil' do
        adapter.find_one(bull: 'shit').should be_nil
      end
    end
  end

end
