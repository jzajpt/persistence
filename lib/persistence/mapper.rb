# encoding: utf-8

require 'singleton'
require 'persistence/adapters/mongo'
require 'persistence/adapters/grid_fs'
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

    attr_accessor :adapter
    attr_accessor :file_adapter

    # Initialize mapper instance
    def initialize(adapter, file_adapter = nil)
      @adapter = adapter
      @file_adapter = file_adapter
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
