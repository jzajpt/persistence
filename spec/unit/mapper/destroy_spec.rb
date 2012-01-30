# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper::Destroy do

  let(:persistence_class) do
    Class.new do
      include Persistence::Mapper::Load
      include Persistence::Mapper::Observers
      include Persistence::Mapper::Destroy
    end
  end
  let(:persistence) { persistence_class.new }

  describe '#destroy' do

    let(:adapter) { double('Adapter', destroy_resource: nil) }
    let(:id)      { BSON::ObjectId.new }

    before do
      persistence.stub(:adapter).and_return(adapter)
      persistence.stub(:find)
    end

    it 'tries to find given object' do
      persistence.should_receive(:find).with id
      persistence.destroy id
    end

    context 'when object exists' do
      let(:object) { Object.new }

      before do
        persistence.stub(:find).and_return object
      end

      it "destroys given resource" do
        adapter.should_receive(:destroy_resource).with id
        persistence.destroy id
      end

      it 'runs observers' do
        persistence.should_receive(:run_observers).with :destroy, object
        persistence.destroy id
      end
    end

    context 'when object doesnt exist' do
      it 'should not call observers' do
        persistence.should_not_receive :run_observers
        persistence.destroy id
      end

      it 'should not try to destroy resource' do
        adapter.should_not_receive :destroy_resource
        persistence.destroy id
      end
    end

  end

end
