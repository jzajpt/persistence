# encoding: utf-8

module Persistence
  class Mapper
    module Criteria
      # Criteria hash.
      # @return [Hash]
      attr_accessor :criteria

      # Options hash.
      # @return [Hash]
      attr_accessor :options

      # Sets select criteria.
      #
      # @param [Hash] criteria
      # @param [Hash] criteria
      # @return [Iterator] New iterator
      def select(criteria = nil)
        new_criteria = @criteria || {}
        new_criteria = new_criteria.merge(criteria) if criteria
        Iterator.new(self.collection_adapter, new_criteria, options)
      end

      # @param [Array] fields Array of fields
      # @return [Iterator] New iterator
      def only(*fields)
        field_selection(1, *fields)
      end

      # @param [Array] fields Array of fields
      # @return [Iterator] New iterator
      def except(*fields)
        field_selection(0, *fields)
      end

      # Sets sort order.
      #
      # @param [Array] order Sort order
      # @return [Iterator] New iterator
      def sort(order)
        new_options = self.options || {}
        if new_options[:sort]
          new_options[:sort] << order
        else
          new_options[:sort] = [order]
        end
        Iterator.new(self.collection_adapter, criteria, new_options)
      end

      protected

      def field_selection(value, *fields)
        new_options = self.options || {}
        fields = Hash[fields.flatten.map {|f| [f, value]}]
        if new_options[:fields]
          new_options[:fields].merge! fields
        else
          new_options[:fields] = fields
        end
        Iterator.new(self.collection_adapter, criteria, new_options)
      end
    end
  end
end
