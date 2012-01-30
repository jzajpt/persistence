# encoding: utf-8

module Persistence
  class Mapper
    module Destroy
      # Destroys resource with given ID.
      #
      # @param [BSON::ObjectID, string] id Resource ID
      def destroy(id)
        object = self.find id
        object && run_observers(:destroy, object) do
          self.collection_adapter.destroy_resource(id)
        end
      end
    end
  end
end
