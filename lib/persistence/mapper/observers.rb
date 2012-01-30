# encoding: utf-8

module Persistence
  class Mapper
    module Observers
      attr_accessor :observer_classes

      # Registers given observer class.
      #
      # @param [Class] observer_class
      def register_observer(observer_class)
        self.observer_classes ||= []
        self.observer_classes.push observer_class
      end

      # Calls observer classes callback with given object.
      #
      # @param [Symbol] callback Callback name
      # @param [Object] object Callback subject
      def call_observers(callback, object)
        classes = self.observer_classes || []
        classes.each do |klass|
          klass.send callback, object if klass.respond_to? callback
        end
      end

      def run_observers(method_name, object, options = {})
        call_observers(:"before_#{method_name}", object) if options[:observers] != false
        yield
        call_observers(:"after_#{method_name}", object) if options[:observers] != false
      end
    end
  end
end
