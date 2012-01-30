# encoding: utf-8

require 'persistence/resource_factory'

module Persistence
  class Mapper
    module Save
      # Persists given object into database.
      #
      # @param [Object] object Domain object
      # @return [Object] Domain object
      def save(object, options = {})
        self.run_observers(:save, object, options) do
          if self.was_persisted?(object)
            self.persist_existing object
          else
            self.persist_new object
          end
        end
        object
      end

      protected

      # Persist new object into database.
      #
      # @param [Object] object Domain object to persist
      # @return [Object] Domain object
      def persist_new(object)
        self.timestamp_create object
        self.timestamp_update object
        resource = self.object_to_resource(object)
        new_id = self.adapter.insert_resource(resource)
        object.id = new_id
        object.instance_variable_set :@type, object.class.name.to_s
        object
      end

      # Persist existing object into database.
      #
      # @param [Object] object Domain object to persist
      # @return [Object] Domain object
      def persist_existing(object)
        self.timestamp_update object
        resource = self.object_to_resource(object)
        self.adapter.update_resource(object.id, resource)
        object
      end

      # Sets +created_at+ timestamp on given object if it has
      # +created_at+ attribute.
      def timestamp_create object
        if object.respond_to? :created_at=
          object.created_at = Time.now.utc
        end
      end

      # Sets +updated_at+ timestamp on given object if it has
      # +updated_at+ attribute.
      def timestamp_update object
        if object.respond_to? :updated_at=
          object.updated_at = Time.now.utc
        end
      end

      # Checks if given object was already persisted or not.
      #
      # @param [Object] object Domain object
      # @return [Boolean] True if object was already persisted, otherwise false
      def was_persisted?(object)
        object && object.respond_to?(:id) && object.id.present?
      end

      # Returns resource hash created from given Domain object.
      #
      # @param [Object] object Domain object
      # @return [Hash] Resource hash
      def object_to_resource(object)
        resource_hash = ResourceFactory.new(object).resourcify
        resource_hash['_type'] = object.class.name.to_s
        resource_hash['_id'] = object.id if self.was_persisted?(object)
        resource_hash
      end
    end
  end
end
