# encoding: utf-8

require 'spec_helper'

describe Persistence::Mapper::Observers do
  let(:persistence_class) do
    Class.new do
      include Persistence::Mapper::Observers
    end
  end
  let(:persistence) { persistence_class.new }

  describe '.register' do
    it 'initializes observers array if it was nil' do
      my_observer = Class.new
      persistence.observer_classes = nil
      persistence.register_observer my_observer
      persistence.observer_classes.should be_kind_of(Array)
    end

    it 'appends given observer class to observer_classes array' do
      my_observer = Class.new
      persistence.observer_classes = nil
      persistence.register_observer my_observer
      persistence.observer_classes.last.should eq(my_observer)
    end
  end

  describe '.call_observers' do
    it 'calls given method on all of its descendants' do
      my_observer = Class.new do
        def self.after_save(object)
        end
      end
      my_observer.should_receive(:after_save).with '123'
      persistence.stub(:observer_classes).and_return [my_observer]
      persistence.call_observers :after_save, '123'
    end

    it 'does not fail when given method doesnt exist' do
      my_observer = Class.new
      persistence.stub(:observer_classes).and_return [my_observer]
      persistence.call_observers :after_save, '123'
    end
  end

  describe '.run_observers' do
    it 'calls "before" callback before yield and "after" callback after yield' do
      observer = Class.new do
        def self.before_save(object)
          object << '1'
        end

        def self.after_save(object)
          object << '3'
        end
      end
      object = ''
      persistence.stub(:observer_classes).and_return [observer]
      persistence.run_observers(:save, object) do
        object << '2'
      end
      object.should eql '123'
    end
  end
end
