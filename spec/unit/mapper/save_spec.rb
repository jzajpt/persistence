# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper::Save do

  let(:persistence_class) do
    Class.new do
      include Persistence::Mapper::Observers
      include Persistence::Mapper::Save
    end
  end
  let(:persistence) { persistence_class.new }

  describe '#save' do

    let(:adapter) { double('Adapter') }
    let(:object_class) do
      Class.new do
        attr_accessor :id
        attr_accessor :name
        attr_accessor :author
        attr_accessor :created_at
        attr_accessor :updated_at
      end
    end
    let(:id) { BSON::ObjectId.new }

    before do
      persistence.stub(:collection_adapter).and_return(adapter)
      object_class.stub(:name).and_return(:object_class)
    end

    context 'new' do

      let(:object) { object_class.new }

      before do
        adapter.stub(:insert_resource).and_return(id)
      end

      it 'sets @type instance variable on object' do
        persistence.save object
        object.instance_variable_get(:@type).should eq(object.class.name.to_s)
      end

      it 'sets created_at timestamp on object' do
        now = Time.now
        Time.stub(:now).and_return now
        persistence.save(object)
        object.created_at.should eq(now.utc)
      end

      it 'sets updated_at timestamp on object' do
        now = Time.now
        Time.stub(:now).and_return now
        persistence.save(object)
        object.updated_at.should eq(now.utc)
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

      it 'sets updated_at timestamp on object' do
        now = Time.now
        Time.stub(:now).and_return now
        persistence.save(object)
        object.updated_at.should eq(now.utc)
      end

      it 'updates existing hash with new values from instance variables' do
        object.name = "The test"
        object.author = "Jonny F"
        hash = { "name" => object.name, "author" => object.author }
        adapter.should_receive(:update_resource).with(id, hash_including(hash)).and_return(id)
        persistence.save(object)
      end

    end

    describe 'observer triggering' do

      let(:object_class) do
        Class.new do
          attr_accessor :id
          attr_accessor :name
        end
      end
      let(:id) { BSON::ObjectId.new }

      before do
        adapter.stub(:insert_resource).and_return(id)
      end

      it 'triggers saved callback on observer' do
        object = object_class.new
        persistence.should_receive(:run_observers).with :save, object, {}
        persistence.save object
      end

      context 'with observers: false option' do
        it 'does not trigger saved callback on observer' do
          object = object_class.new
          persistence.should_not_receive(:call_observers)
          persistence.save object, observers: false
        end
      end

    end
  end
end

