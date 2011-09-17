# encoding: utf-8

require 'spec_helper'

describe Persistence::Adapters::GridFs do

  let(:db_adapter) { Persistence.adapter }
  let(:adapter)    { Persistence::Adapters::GridFs.new(database: db_adapter.database) }
  let(:db)         { adapter.database }
  let(:original_file) { File.new(File.join(File.dirname(__FILE__), "/../fixtures/file.txt")) }

  describe "#push_file" do


    it "returns an id of created file" do
      new_id = adapter.push_file(original_file, 'file.txt')
      new_id.should be_kind_of(BSON::ObjectId)
    end

    it "allows to specify ID to be assigned" do
      my_id = BSON::ObjectId.new
      new_id = adapter.push_file(original_file, 'file.txt', my_id)
      new_id.should eq(my_id)
    end

    it "uploads a file content to GridFS store" do
      new_id = adapter.push_file(original_file, 'file.txt')
      grid = Mongo::Grid.new(db)
      grid_file = grid.get(new_id)
      original_file.rewind
      grid_file.read.should eq(original_file.read)
    end

  end

  describe "#metadata" do

    let(:grid) { Mongo::Grid.new(db) }

    before do
      @id = grid.put(original_file, filename: 'file.txt')
    end

    context "with existing file ID" do

      it "returns metadata hash" do
        adapter.metadata(@id).should be_kind_of(Hash)
      end

      it "returns original filename inside metadata" do
        metadata = adapter.metadata(@id)
        metadata[:filename].should eq('file.txt')
      end

      it "returns content type inside metadata" do
        metadata = adapter.metadata(@id)
        metadata[:content_type].should eq('text/plain')
      end

      it "doesn't mind string typed ID" do
        adapter.metadata("#{@id}").should_not be_nil
      end

    end

    context "with non-existing file ID" do

      it "returns metadata hash" do
        adapter.metadata(BSON::ObjectId.new).should be_nil
      end

    end

  end

  describe "#get_file" do

    context "with existing file ID" do

      let(:grid) { Mongo::Grid.new(db) }

      before do
        @id = grid.put(original_file, filename: 'file.txt')
      end

      it "returns a file content" do
        content = adapter.get_file(@id)
        original_file.rewind
        content.should eq(original_file.read)
      end

      it "doesn't mind string typed ID" do
        expect { adapter.get_file("#{@id}") }.to_not raise_error
      end

    end

    context "with non-existing file ID" do

      it "raises an error" do
        expect { adapter.get_file(BSON::ObjectId.new) }.to raise_error(Mongo::GridFileNotFound)
      end

    end

  end

  describe "#delete_file" do

    context "with existing file ID" do

      let(:grid) { Mongo::Grid.new(db) }

      before do
        @id = grid.put(original_file, filename: 'file.txt')
      end

      it "removes stored file" do
        adapter.delete_file(@id)
        expect { grid.get(@id) }.to raise_error(Mongo::GridFileNotFound)
      end

      it "returns true" do
        adapter.delete_file(@id).should be_true
      end

      it "doesn't mind string typed ID" do
        adapter.delete_file("#{@id}").should be_true
      end

    end

    context "with non-existing file ID" do

      it "returns false" do
        adapter.delete_file(BSON::ObjectId.new).should be_false
      end

    end

  end

end

