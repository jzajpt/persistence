# encoding: utf-8

module Persistence

  module Factory

    # Creates new object of given class
    #
    # @param [Class, String, Symbol] klass Class
    # @return [Object] Object of given class
    def self.new(klass, attributes = {})
      klass = klass.respond_to?(:constantize) ? klass.constantize : klass
      klass.new.tap do |object|
        self.assign object, attributes
      end
    end

    # Assigns given resource to given object.
    #
    # @param [Object] object Domain object
    # @param [Hash] hash Resource hash from database
    # @return [Object] Domain object
    def self.assign(object, resource)
      resource_id = resource.delete('_id')
      object.instance_variable_set :"@id", resource_id if resource_id
      resource.each do |key, value|
        var_name = :"@#{key}"
        object.instance_variable_set var_name, value
      end
    end

  end

end

