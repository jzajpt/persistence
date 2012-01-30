# encoding: utf-8

require 'persistence/adapters/mongo'
require 'persistence/adapters/grid_fs'

module Persistence

  module Base

    attr_accessor :adapter
    attr_accessor :file_adapter

    # Initializes persistence from given YAML file.
    #
    # @param [String] file_name File name with YAML config file
    def init_from_yml(file_name, environment = 'development')
      config_hash = YAML.load_file(file_name)[environment]
      raise ArgumentError unless config_hash
      self.init_persistence(config_hash.symbolize_keys)
    end

    # Initializes persitence layer
    #
    # @param [Hash] options Config hash
    # @option options [String] :host Database name
    # @option options [String] :database Database name
    # @option options [String] :collection Collection name
    # @return [Persistence::Base]
    def init_persistence(options = {})
      self.adapter = Adapters::Mongo.new(options)
      self.file_adapter = Adapters::GridFs.new(database: self.adapter.database)
      self
    end

  end

end
