# encoding: utf-8

require 'spec_helper'

describe Persistence::Adapters::MongoDatabaseAdapter do
  let(:options) { { host: 'localhost', database_name: 'persistence_test' } }
  let(:adapter) { Persistence::Adapters::MongoDatabaseAdapter.new options }
  let(:db)      { adapter.database }
  let(:coll)    { adapter.collection }

  it 'connects to given database' do
    expect { adapter.connect }.not_to raise_error
  end

  it 'responds when connected' do
    adapter.connect
    adapter.should be_connected
  end

  it 'can disconnect' do
    adapter.connect
    adapter.disconnect
    adapter.should_not be_connected
  end
end
