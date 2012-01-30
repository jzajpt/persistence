# encoding: utf-8

module Persistence
  module Adapters
    class AbstractDatabaseAdapter
      def connect
      end

      def connected?
      end

      def disconnect
      end
    end
  end
end

