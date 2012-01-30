# encoding: utf-8

require 'persistence/mapper/criteria'

module Persistence
  class Mapper
    class Iterator
      include ::Enumerable
      include Criteria

      attr_accessor :collection_adapter

      # Initializes iterator class.
      #
      # @param [Hash] criteria Criteria
      # @param [Hash] options Options
      def initialize(collection_adapter, criteria = nil, options = nil)
        @collection_adapter = collection_adapter
        @criteria = criteria || {}
        @options = options || {}
      end

      # Yields block for each object in iterator.
      #
      # @param [Block] block Block to yield
      def each(&block)
        self.to_a.each do |object|
          block.call(object)
        end
      end

      # Convenience method signaling end of method chain.
      #
      # @return [Iterator] Returns iterator itself
      def all
        self
      end

      # Returns array.
      #
      # @return [Array] Iterator objects
      def to_a
        resources = self.collection_adapter.find(criteria, safe_options)
        resources.map do |hash|
          ObjectFactory.new(hash).materialize
        end.compact
      end

      # Returns first object in iterator
      #
      # @return [Object] First objects
      def first
        hash = self.collection_adapter.find_one criteria, safe_options
        ObjectFactory.new(hash).materialize if hash
      end

      # Returns number of objects.
      #
      # @return [Number] Number of objects
      def count
        to_a.count
      end

      protected

      def safe_options
        fields = options[:fields]
        if fields && !fields.empty? && fields.values.all? {|x| x == 1}
          fields[:_type] = 1
        end
        options
      end
    end
  end
end
