
# encoding: utf-8

require 'spec_helper'

describe Persistence::Files do

  let(:persistence_class) do
    Class.new do
      include Persistence::Base
      include Persistence::Files
    end
  end
  let(:persistence) { persistence_class.new }
  let(:file_adapter) { double('FileAdapter', push_file: nil, get_file: nil) }

  describe '#push_file' do

    before do
      persistence.file_adapter = file_adapter
    end

    it 'delegates to file_adapter' do
      file_adapter.should_receive(:push_file)
      persistence.push_file
    end

  end

  describe '#file_metadata' do

    before do
      persistence.file_adapter = file_adapter
    end

    it 'delegates to file_adapter' do
      file_adapter.should_receive(:metadata).with('123')
      persistence.file_metadata('123')
    end

  end

  describe '#get_file' do

    before do
      persistence.file_adapter = file_adapter
    end

    it 'delegates to file_adapter' do
      file_adapter.should_receive(:get_file)
      persistence.get_file
    end

  end

  describe '#delete_file' do

    before do
      persistence.file_adapter = file_adapter
    end

    it 'delegates to file_adapter' do
      file_adapter.should_receive(:delete_file)
      persistence.delete_file
    end

  end

end

