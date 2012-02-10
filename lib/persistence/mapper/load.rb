# encoding: utf-8

module Persistence
  class Mapper
    module Load
      # Finds the learning object by given ID.
      #
      # @param [BSON::ObjectID] id
      # @param [Object] Materialized object
      def find(id, options = {})
        iterator = self.select(_id: id)
        iterator.except(options[:except]) if options[:except]
        iterator.first
      end

      # Returns the first object from collection.
      #
      # @param [Object] Materialized object
      def first
        Iterator.new(self.collection_adapter).first
      end

      # Returns the array with all learning objects.
      #
      # @return [Array] The array with learning objects.
      def all
        self.collection_adapter.resources.map do |hash|
          ObjectFactory.new(hash).materialize
        end.compact
      end
    end
  end
end
