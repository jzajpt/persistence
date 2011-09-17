# encoding: utf-8

module Persistence

  module Destroy

    # Destroys resource with given ID.
    #
    # @param [BSON::ObjectID, string] id Resource ID
    def destroy(id)
      self.adapter.destroy_resource(id)
    end

  end

end
