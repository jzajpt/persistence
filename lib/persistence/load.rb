# encoding: utf-8

module Persistence

  module Load

    # Identity map of objects with ids as keys
    # @return [Array]
    attr_accessor :identity_map

    # Called when module is extended on another.
    #
    # @param [Class, Module] base Receiver class or module
    def self.extended(base)
      base.reset
    end

    # Loads the learning object by given ID.
    #
    # @param [BSON::ObjectID] id
    # @param [Object] Materialized object
    def load(id)
      self.from_identity_map_or(id) do
        hash = self.adapter.resource(id)
        self.materialize(id, hash) if hash
      end
    end

    # Returns the array with all learning objects.
    #
    # @return [Array] The array with learning objects.
    def all
      self.adapter.resources.map do |hash|
        self.from_identity_map_or(hash['_id']) do
          self.materialize(hash['_id'], hash)
        end
      end.compact
    end

    # Resets identity map.
    def reset
      self.identity_map = {}
    end

    protected

    # Returns materialized class instance.
    #
    # @param [BSON::ObjectId] object_id Object ID
    # @param [Hash] hash Object content
    # @return [Object] Materialized object
    def materialize(id, hash)
      type = hash.delete '_type'
      return unless type
      klass = type.constantize
      klass.new.tap do |object|
        self.assign object, hash
        self.identity_map[id] = object
      end
    end

    # Assigns given resource to given object.
    #
    # @param [Object] object Domain object
    # @param [Hash] hash Resource hash from database
    # @return [Object] Domain object
    def assign(object, resource)
      resource_id = resource.delete('_id')
      object.instance_variable_set :"@id", resource_id if resource_id
      resource.each do |key, value|
        var_name = :"@#{key}"
        object.instance_variable_set var_name, value
      end
    end

    # Tries to load given resource from identity map or
    # calls given block.
    #
    # @param [BSON::ObjectId] id Object id
    # @return Given object from identity map or return value of given
    # block
    def from_identity_map_or(id, &block)
      if self.identity_map.has_key?(id)
        self.identity_map[id]
      else
        yield
      end
    end

  end

end
