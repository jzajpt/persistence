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
      # @option options [String] :host MongoDB host
      # @option options [String] :port MongoDB port
      # @option options [String] :database Database name
      # @option options [String] :collection Collection name
      # @option options [String] :logger Logger
      def initialize(options = {})
        @connection = ::Mongo::Connection.new(options[:host], options[:port], logger: options[:logger])
        @database = @connection.db(options[:database])
        self.collection(options[:collection]) if options[:collection]
      end

      # Returns a persisted hash of given document.
      #
      # @param [String, BSON::ObjectId] id The ID of document to return
      # @return [Hash] A hash of given document
      def resource(id = nil, options = {})
        self.normalize(collection.find_one(self.to_id(id), options))
      end

      # Returns all persisted documents
      #
      # @return [Array] Array of persisted hashes
      def resources
        self.collection.find({}, :sort => [:_id, :asc]).map do |hash|
          self.normalize hash
        end
      end

      # Returns persisted documents matching to given criteria.
      #
      # @param [Hash] criteria Criteria
      # @param [Hash] options Options
      # @return [Array] Array of matched hashes
      def find(criteria, options = {})
        criteria = normalize_criteria criteria
        self.collection.find(criteria, options).map do |hash|
          self.normalize hash
        end
      end

      # Returns first persisted document matching to given criteria.
      #
      # @param [Hash] criteria Criteria
      # @param [Hash] options Options
      # @return [Hash] First matched document
      def find_one(criteria, options = {})
        criteria = normalize_criteria criteria
        hash = self.collection.find_one(criteria, options)
        self.normalize(hash) if hash
      end

      # Inserts a new object into collection
      #
      # @param [Hash] doc The hash to persist
      def insert_resource(doc)
        self.collection.insert(doc)
      end

      # Replaces existing object with new one.
      #
      # @param [String, BSON::ObjectId] id The ID of resource
      # @param [Hash] new_doc New hash to persist
      # @return [BSON::ObjectId, nil] ID of updated resource or nil
      def replace_resource(id, new_doc)
        id = self.to_id(id)
        result = self.collection.update({ _id: id }, new_doc, safe: true)
        if self.update_result_ok?(result)
          id
        else
          nil
        end
      end

      # Updates existing object keys and values from given hash.
      #
      # @param [String, BSON::ObjectId] id The ID of resource
      # @param [Hash] new_doc New hash to set
      # @return [BSON::ObjectId, nil] ID of updated resource or nil
      def update_resource(id, new_doc)
        id = self.to_id(id)
        document = { "$set" => new_doc.except("_id", :_id) }
        result = self.collection.update({ _id: id }, document, safe: true)
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

      # Normalizes hash from Mongo driver.
      #
      # @param [Hash] hash Hash to normalize
      # @return [Hash] Normalized hash
      def normalize(hash)
        hash.symbolize_keys if hash
      end

      # Normalizes criteria hash
      #
      # @param [Hash] criteria_hash Criteria hash to normalize
      # @return [Hash] Normalized hash
      def normalize_criteria(criteria_hash)
        if criteria_hash[:_id].present?
          criteria_hash[:_id] = to_id criteria_hash[:_id]
        end
        criteria_hash
      end

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

      # Returns logger instance for mongo connection.
      #
      # @return [Logger] Logger instance
      def logger
        @_logger ||= Rails.logger
      end

    end

  end

end
