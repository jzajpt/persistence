# encoding: utf-8

module Persistence
  module Adapters
    class AbstractCollectionAdapter
      attr_accessor :database_adapter
      attr_accessor :collection_name

      def initialize(database_adapter, collection_name)
        @database_adapter = database_adapter
        @collection_name = collection_name
      end
    end
  end
end


