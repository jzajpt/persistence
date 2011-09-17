# encoding: utf-8

require 'persistence'

module Rack

  module Persistence

    # Middleware that resets Persistence identity map before at the
    # start of every rack call.
    class IdentityMap

      # Initialize the new middleware object.
      #
      # @param [Object] app The application.
      def initialize(app)
        @app = app
      end

      # Make the request with the provided environment.
      #
      # @param [Object] env The environment.
      def call(env)
        ::Persistence.reset
        @app.call(env)
      end

    end

  end

end

