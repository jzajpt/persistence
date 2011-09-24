# encoding: utf-8

require 'persistence/criteria'

module Persistence

  class Iterator

    include ::Enumerable

    include Criteria

    # Initializes iterator class.
    #
    # @param [Hash] Criteria
    def initialize(criteria = {})
      self.criteria = criteria
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
      Persistence.adapter.find(self.criteria || {})
    end

    # Returns first object in iterator
    #
    # @return [Object] First objects
    def first
      to_a.first
    end

    # Returns last object in iterator
    #
    # @return [Object] Last objects
    def last
      to_a.last
    end

    # Returns number of objects.
    #
    # @return [Number] Number of objects
    def count
      to_a.count
    end

  end

end

