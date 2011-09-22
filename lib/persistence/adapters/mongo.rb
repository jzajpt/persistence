# encoding: utf-8

module Persistence

  module Adapters

    # MongoDB database adapter.
    #
    # @author Jiri Zajpt
    class Mongo

      attr_accessor :connection
      attr_accessor :database

      # Initializes adapter with given options.
      #
      # @param [Hash] options Options hash
      # @option options [String] :host Host
      # @option options [String] :database Database name
      # @option options [String] :collection Collection name
      def initialize(options = {})
        @connection = ::Mongo::Connection.new(options[:host])
        @database = @connection.db(options[:database])
        self.collection(options[:collection]) if options[:collection]
      end

      # Returns a persisted hash of given document.
      #
      # @param [String, BSON::ObjectId] id The ID of document to return
      # @return [Hash] A hash of given document
      def resource(id = nil)
        collection.find_one(self.to_id(id))
      end

      # Returns all persisted documents
      #
      # @return [Array] Array of persisted hashes
      def resources
        self.collection.find.to_a
      end

      # Returns persisted documents matching to given criteria.
      #
      # @param [Hash] Criteria
      # @return [Array] Array of matched hashes
      def find(criteria)
        self.collection.find(criteria).to_a
      end

      # Inserts a new object into collection
      #
      # @param [Hash] doc The hash to persist
      def insert_resource(doc)
        self.collection.insert(doc)
      end

      # Updates existing object with new one
      #
      # @param [String, BSON::ObjectId] id The ID of resource
      # @param [Hash] new_doc New hash to persist
      # @return [BSON::ObjectId, nil] ID of updated resource or nil
      def update_resource(id, new_doc)
        id = self.to_id(id)
        result = self.collection.update({ _id: id }, new_doc, safe: true)
        if self.update_result_ok?(result)
          id
        else
          nil
        end
      end

      # Destroys existing object
      #
      # @param [String, BSON::ObjectId] id The ID of document to destroy
      # @return [BSON::ObjectId, nil] ID of updated resource or nil
      def destroy_resource(id)
        id = self.to_id(id)
        result = self.collection.remove({ _id: id }, safe: true)
        if self.remove_result_ok?(result)
          id
        else
          nil
        end
      end

      # Uses given collection or returns the current one used.
      #
      # @param [String, nil] name The collection name
      # @return [Collection]
      def collection(name = nil)
        @_coll = name.present? ? self.database[name] : @_coll
      end

      protected

      # Checks if update result hash returned error or not.
      #
      # @param [Hash] update_result Result of update call
      # @return [true, false] True if update was ok, false if result contained error
      def update_result_ok?(update_result)
        update_result.is_a?(Hash) && update_result["updatedExisting"] == true
      end

      # Checks if remove result hash contains error and if exactly one
      # document was removed.
      #
      # @param [Hash] remove_result Result of remove call
      # @return [true, false] True if remove was ok, false if result contained error
      def remove_result_ok?(remove_result)
        remove_result.is_a?(Hash) && remove_result["err"] == nil && remove_result["n"] == 1
      end

      # Converts given string to BSON::ObjectId.
      #
      # @param [String] id
      # @return [BSON::ObjectId]
      def to_id(id)
        id.kind_of?(BSON::ObjectId) ? id : BSON::ObjectId(id)
      end

    end

  end

end
