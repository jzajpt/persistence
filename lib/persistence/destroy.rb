# encoding: utf-8

module Persistence

  module Destroy

    # Destroys resource with given ID.
    #
    # @param [BSON::ObjectID, string] id Resource ID
    def destroy(id)
      if self.adapter.destroy_resource(id)
        self.identity_map.delete(id)
        id
      end
    end

  end

end
