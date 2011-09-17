# encoding: utf-8

module Persistence

  module Save

    # Persists given object into database.
    #
    # @param [Object] object Domain object
    # @return [Object] Domain object
    def save(object)
      if self.was_persisted?(object)
        self.persist_existing(object)
      else
        self.persist_new(object)
      end
    end

    protected

    # Persist existing object into database.
    #
    # @param [Object] object Domain object to persist
    # @return [Object] Domain object
    def persist_existing(object)
      resource = self.object_to_resource(object)
      self.adapter.update_resource(object.id, resource)
      object
    end

    # Persist new object into database.
    #
    # @param [Object] object Domain object to persist
    # @return [Object] Domain object
    def persist_new(object)
      resource = self.object_to_resource(object)
      new_id = self.adapter.insert_resource(resource)
      object.id = new_id
      object
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
      resource_hash = if object.respond_to?(:to_resource)
        object.to_resource
      else
        self.resource_from_instance_variables(object)
      end
      resource_hash['_type'] = object.class.name.to_s
      resource_hash['_id'] = object.id if self.was_persisted?(object)
      resource_hash
    end

    # Creates resource hash from object's instance variables.
    #
    # @param [Object] object Domain object
    # @return [Hash] Resource hash
    def resource_from_instance_variables(object)
      vars = object.instance_variables
      vars.inject({}) do |hash, var_name|
        value = object.instance_variable_get var_name
        key = var_name.to_s.match(/@(.+)/)[1]
        hash[key] = value
        hash
      end
    end

  end

end
