# encoding: utf-8

require 'singleton'
require 'persistence/adapters/mongo_collection_adapter'
require 'persistence/mapper/criteria'
require 'persistence/mapper/destroy'
require 'persistence/mapper/files'
require 'persistence/mapper/iterator'
require 'persistence/mapper/load'
require 'persistence/mapper/observers'
require 'persistence/mapper/save'

module Persistence
  class Mapper
    include Load
    include Save
    include Destroy
    include Files
    include Criteria
    include Observers

    attr_accessor :database_adapter
    attr_accessor :collection_adapter
    attr_accessor :file_adapter

    # Initialize mapper instance
    def initialize(database_adapter, file_adapter = nil)
      @database_adapter = database_adapter
      @file_adapter = file_adapter
      @collection_adapter = Adapters::MongoCollectionAdapter.new database_adapter, collection_name
    end

    def collection_name
      class_name = self.class.name
      resource = class_name.match(/^(.+)Mapper$/)[1]
      resource.tableize if resource
    end

    class << self
      attr_accessor :instance

      def method_missing(method_name, *args)
        if instance.respond_to?(method_name)
          instance.send(method_name, *args)
        else
          super(method_name, *args)
        end
      end

      def respond_to?(method_name)
        super(method_name) || instance.respond_to?(method_name)
      end
    end
  end
end
