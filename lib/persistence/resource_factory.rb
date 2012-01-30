module Persistence
  class ResourceFactory
    attr_accessor :options

    # Initialize ObjectFactory instance
    #
    # @param [Object] object Object
    # @param [Hash] options with :except key
    def initialize(object, options = {})
      @object = object
      @options = options
    end

    # Creates resource hash from object's instance variables.
    def resourcify
      except = @options[:except] ? [@options[:except]].flatten : []
      only   = @options[:only]
      vars   = @object.instance_variables
      vars   = only ? (vars & [only].flatten) : (vars - except)

      vars.inject({}) do |hash, var_name|
        value = @object.instance_variable_get var_name
        key = var_name.to_s.match(/@(.+)/)[1]
        key = "_#{key}" if key == 'id' || key == 'type'
        hash[key] = value
        hash
      end
    end
  end
end
