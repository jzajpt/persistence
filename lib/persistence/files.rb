# encoding: utf-8

require 'active_support/core_ext'

module Persistence

  module Files

    # Pushes the file into persistence store and returns it's ID.
    #
    # @param [File] source the file or filename
    # @return [String] ID assigned to file
    delegate :push_file, to: :file_adapter

    # Retreives the file from persistence store and returns it's
    # content.
    #
    # @param [String] id the ID of the file
    # @return [String] file content
    delegate :get_file, to: :file_adapter

    # Deletes the file from persistence store.
    #
    # @param [String] id the ID of the file
    # @return [true, false] True if file was deleted, otherwise false
    delegate :delete_file, to: :file_adapter

    # Returns metadate for given file ID.
    #
    # @param [BSON::ObjectId, String] id File ID
    # @return [Hash] File metdata
    def file_metadata(id)
      self.file_adapter.metadata(id)
    end

  end

end
