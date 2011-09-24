# encoding: utf-8

require 'spec_helper'

describe Rack::Persistence::IdentityMap do

  let(:my_app)     { double('MyApp', call: nil) }
  let(:middleware) { Rack::Persistence::IdentityMap.new(my_app) }

  describe '#initialize' do

    it 'sets @app instance variable' do
      middleware.instance_variable_get(:@app).should eq(my_app)
    end

  end

  describe '#call' do

    it 'calls Persistence.reset before calling app' do
      ::Persistence.should_receive(:reset).ordered
      middleware.call({})
    end

    it 'calls app with given parameter' do
      ::Persistence.stub(:reset)
      my_app.should_receive(:call).with('ohai')
      my_app.call('ohai')
    end

  end

end


