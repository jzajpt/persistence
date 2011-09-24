# encoding: utf-8

require 'spec_helper'

describe Persistence::Save do

  let(:persistence) do
    Class.new do
      extend Persistence::Base
      extend Persistence::Save
    end
  end

  describe '#save' do

    let(:adapter) { double('Adapter') }

    before do
      persistence.stub(:adapter).and_return(adapter)
    end

    context 'object with #to_resource method' do

      let(:object_class) do
        Class.new do
          attr_accessor :id
          attr_accessor :name
          attr_accessor :author
          def to_resource
            { "title" => @name, "author" => @author }
          end
        end
      end
      let(:id)     { BSON::ObjectId.new }
      let(:object) { object_class.new }

      before do
        object_class.stub(:name).and_return(:object_class)
      end

      context "new " do

        before do
          adapter.stub(:insert_resource).and_return(id)
          object.name = "A test"
          object.author = "Jonny Q"
        end

        it 'persists hash from #to_resource method' do
          adapter.should_receive(:insert_resource).with(hash_including(object.to_resource)).and_return(id)
          persistence.save(object)
        end

        it "does not provide any ID to the adapter" do
          adapter.should_receive(:insert_resource).with(hash_not_including(%w(id _id))).and_return(id)
          persistence.save(object)
        end

        it "persists object class name" do
          type_hash = { "_type" => "object_class" }
          adapter.should_receive(:insert_resource).with(hash_including(type_hash)).and_return(id)
          persistence.save(object)
        end

        it 'assigns new ID to object after persisting object' do
          -> {
            persistence.save(object)
          }.should change(object, :id).to(id)
        end

      end

      context "already persisted" do

        let(:object) { object_class.new }

        before do
          adapter.stub(:update_resource).and_return(id)
          object.id = id
        end

        it 'does not persist new hash' do
          adapter.should_not_receive(:insert_resource)
          persistence.save(object)
        end

        it 'inserts document ID as _id' do
          hash = { "_id" => id }
          adapter.should_receive(:update_resource).with(id, hash_including(hash)).and_return(id)
          persistence.save(object)
        end

        it "persists object class name" do
          type_hash = { "_type" => "object_class" }
          adapter.should_receive(:update_resource).with(id, hash_including(type_hash)).and_return(id)
          persistence.save(object)
        end

      end

    end

    context 'object without #to_resource method' do

      let(:object_class) do
        Class.new do
          attr_accessor :id
          attr_accessor :name
          attr_accessor :author
        end
      end
      let(:id) { BSON::ObjectId.new }

      before do
        object_class.stub(:name).and_return(:object_class)
      end

      context 'new' do

        let(:object) { object_class.new }

        before do
          adapter.stub(:insert_resource).and_return(id)
        end

        it 'persists instance variables from given object' do
          object.name = "A test"
          object.author = "Jonny Q"
          hash = { "name" => object.name, "author" => object.author }
          adapter.should_receive(:insert_resource).with(hash_including(hash)).and_return(id)
          persistence.save(object)
        end

      end

      context 'previously persisted' do

        let(:object) { object_class.new }

        before do
          object.id = id
          adapter.stub(:update_resource).and_return(id)
        end

        it 'updates existing hash with new values from instance variables' do
          object.name = "The test"
          object.author = "Jonny F"
          hash = { "name" => object.name, "author" => object.author }
          adapter.should_receive(:update_resource).with(id, hash_including(hash)).and_return(id)
          persistence.save(object)
        end

      end

    end

  end

end

