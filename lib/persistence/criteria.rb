# encoding: utf-8

module Persistence

  module Criteria

    # Criteria hash.
    # @return [Hash]
    attr_accessor :criteria

    # @param [Hash, Class] class_or_criteria
    # @param [Hash] criteria
    # @return [Object] Returns itself
    def select(class_or_criteria, criteria = nil)
      new_criteria = self.criteria || {}
      if class_or_criteria.is_a?(Class)
        new_criteria = new_criteria.merge(_type: class_or_criteria.to_s)
      end
      if criteria.respond_to?(:to_hash) || class_or_criteria.respond_to?(:to_hash)
        new_criteria = new_criteria.merge(criteria || class_or_criteria)
      end
      Iterator.new(new_criteria)
    end

    # Handles unknown method calls.
    #
    # @param [Symbol] method Method name
    def method_missing(method)
      begin
        class_name = method.to_s.classify
        klass = class_name.constantize
        self.select(klass)
      rescue NameError
        super
      end
    end

  end

end

