# encoding: utf-8

require 'persistence/adapters/abstract_database_adapter'

module Persistence
  module Adapters
    class Mongo < AbstractDatabaseAdapter
      attr_accessor :host
      attr_accessor :port
      attr_accessor :database_name
      attr_accessor :logger
      attr_accessor :connection
      attr_accessor :database

      # Initializes adapter with given options.
      #
      # @param [Hash] options Options hash
      # @option options [String] :host MongoDB host
      # @option options [String] :port MongoDB port
      # @option options [String] :database_name Database name
      # @option options [String] :logger Logger
      def initialize(options)
        @host = options[:host]
        @port = options[:port]
        @database_name = options[:database_name]
      end

      def connect
        @connection = ::Mongo::Connection.new @host, @port, logger: @logger
        @database = @connection.db @database_name
      end

      def disconnect
        @database = nil
        @connection = nil
      end

      def connected?
        @connection.connected? if @connection
      end

      # Returns logger instance for mongo connection.
      #
      # @return [Logger] Logger instance
      def logger
        @_logger ||= Rails.logger
      end
    end
  end
end
