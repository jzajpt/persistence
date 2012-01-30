# encoding: utf-8

require 'spec_helper'

describe Persistence::Adapters::AbstractCollectionAdapter do
  describe '#initialize' do
    let(:database_adapter) { mock "DatabaseAdapter" }
    let(:collection_name) { "my_collection" }
    let(:adapter) { Persistence::Adapters::AbstractCollectionAdapter.new database_adapter }

    it 'assigns database_adapter' do
      adapter.database_adapter.should eq database_adapter
    end

    it 'assigns collection_name' do
      adapter.collection_name.should eq collection_name
    end
  end
end
