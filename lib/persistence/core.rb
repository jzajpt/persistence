# encoding: utf-8

require 'persistence/adapters/mongo_database_adapter'
require 'persistence/adapters/grid_fs_adapter'

module Persistence
  class Core
    attr_accessor :database_adapter
    attr_accessor :file_adapter

    # Initializes persitence core
    #
    # @param [Hash] options Config hash
    # @option options [String] :host Database name
    # @option options [String] :database Database name
    # @option options [String] :collection Collection name
    def initialize(config = {})
      init_adapters config.symbolize_keys
      @mappers = {}
    end

    def register_mapper(key, mapper_class)
      mapper_instance = mapper_class.new(@database_adapter, @file_adapter)
      mapper_class.instance = mapper_instance
      @mappers[key] = mapper_instance
    end

    def mapper(key)
      @mappers[key]
    end

    protected

    def init_adapters(options = {})
      @database_adapter = Adapters::MongoDatabaseAdapter.new(options)
      @database_adapter.connect
      @file_adapter = Adapters::GridFsAdapter.new(database: @database_adapter.database)
    end
  end
end
