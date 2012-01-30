# encoding: utf-8

module Persistence
  class ObjectFactory
    # Initialize ObjectFactory instance
    #
    # @param [Hash] hash Object content
    # @param [Hash] hash with :except key
    def initialize(hash, options = {})
      @hash = hash
      @options = options
    end

    # Materialize object
    #
    # @return [Object] Materialized object of given class
    def materialize
      type = @hash.delete(:_type)
      @hash[:type] = type
      return unless type
      klass = type.constantize
      klass.new.tap do |object|
        self.assign(object, @hash, @options)
      end
    end

    protected

    # Assigns given resource to given object.
    #
    # @param [Object] object Domain object
    # @param [Hash] hash Resource hash from database
    # @param [Hash] hash with :except key
    # @return [Object] Domain object
    def assign(object, resource, options = {})
      except = [options[:except]].flatten.map(&:to_s)

      resource_id = resource.delete(:_id)
      object.instance_variable_set :"@id", resource_id if resource_id
      resource.each do |key, value|
        next if except.include? key
        var_name = :"@#{key}"
        object.instance_variable_set var_name, value
      end
    end
  end
end
