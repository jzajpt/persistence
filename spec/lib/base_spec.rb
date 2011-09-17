# encoding: utf-8

require 'spec_helper'

describe Persistence::Base do

  let(:persistence_class) do
    Class.new do
      include Persistence::Base
    end
  end
  let(:persistence) { persistence_class.new }

  describe '#init_from_yaml' do

    let(:file_name) { 'test.yml' }

    before do
      YAML.stub(:load_file).and_return("test" => {})
      persistence.stub(:init_persistence)
    end

    it 'loads YAML file' do
      YAML.should_receive(:load_file).with(file_name).and_return("test" => {})
      persistence.init_from_yml(file_name)
    end

    it "calls #init_persistence method" do
      hash = { host: 'localhost', database: 'test' }
      YAML.stub(:load_file).and_return("test" => hash)
      persistence.should_receive(:init_persistence).with(hash)
      persistence.init_from_yml(file_name)
    end

  end

end
