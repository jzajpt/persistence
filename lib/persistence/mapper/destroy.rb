# encoding: utf-8

module Persistence
  class Mapper
    module Destroy
      # Destroys resource with given ID.
      #
      # @param [BSON::ObjectID, string] id Resource ID
      def destroy(id_or_object)
        if object_with_id?(id_or_object)
          object = id_or_object
        else
          object = self.find id_or_object
          return unless object
        end
        destroy_object object
      end

      protected

      def destroy_object(object)
        run_observers(:destroy, object) do
          self.collection_adapter.destroy_resource(object.id)
        end
      end

      def object_with_id?(object)
        object.respond_to?(:id) && object.id.present?
      end
    end
  end
end
