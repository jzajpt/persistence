# encoding: utf-8

describe Persistence::ResourceFactory do
  describe '#resourcify' do
    let(:object_class) do
      Class.new do
        attr_accessor :id
        attr_accessor :name
        attr_accessor :author
        attr_accessor :created_at
        attr_accessor :updated_at
      end
    end
    let(:object) { object_class.new }
    let(:id) { BSON::ObjectId.new }
    let(:resource_factory) { Persistence::ResourceFactory.new object }

    before do
      object_class.stub(:name).and_return(:object_class)
    end

    it 'should not present id, type' do
      resource_factory.resourcify['id'].should be_nil
      resource_factory.resourcify['type'].should be_nil
    end

    it 'presents instanace variables of object as hash' do
      object.name = "The test"
      resource_factory.resourcify['name'].should eq 'The test'
    end

    it "doesn't present excepted variables" do
      object.name   = "The test"
      object.author = "Jonny F"
      resource_factory.options = { except: [:@id, :@name, :@author] }
      resource = resource_factory.resourcify
      resource['name'].should be_nil
      resource['author'].should be_nil
      resource['id'].should be_nil
      resource['_id'].should be_nil
    end

    it 'presents only variables passed in "only" key' do
      object.name = "The test"
      object.author = "Jonny F"
      resource_factory.options = { only: [:@id, :@name] }
      resource = resource_factory.resourcify
      resource['name'].should eq 'The test'
      resource['author'].should be_nil
      resource['id'].should be_nil
      resource['_id'].should be_nil
    end

  end
end
