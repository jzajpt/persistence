# encoding: utf-8

require 'mime/types'

module Persistence

  module Adapters

    # GridFS filesystem adapter. Stores and loads files.
    #
    # @author Jiri Zajpt
    class GridFs

      attr_accessor :database
      attr_accessor :grid

      # Intializes adapter with given options.
      #
      # @param [Hash] options Options hash
      # @option options [Mongo::DB] :database Database object
      # instance.
      def initialize(options = {})
        @database = options[:database]
        @grid = ::Mongo::Grid.new(@database)
      end

      # Returns file metadata (filename, content type).
      #
      # @param [BSON::ObjectId, String] id File ID
      # @return [Hash] Metadata hash
      def metadata(id)
        id = self.to_id(id)
        io = self.grid.get(id)
        { filename: io.filename, content_type: io.content_type }
      rescue ::Mongo::GridFileNotFound
        nil
      end

      # Pushes the file into persistence store and returns it's id.
      #
      # @param [File] source File or filename
      # @return [BSON::ObjectId] ID assigned to file
      def push_file(source, original_filename, id = nil)
        data = self.read_from(source)
        self.grid.put(data, filename: original_filename, _id: id)
      end

      # Retreives the file from persistence store and returns it's
      # content.
      #
      # @param [BSON::ObjectId, String] id File ID
      # @return [String] file content
      def get_file(id)
        id = self.to_id(id)
        self.grid.get(id).read
      end

      # Deletes the file from persistence store. Returns true if file
      # was removed, otherwise return false.
      #
      # @param [BSON::ObjectId, String] id File ID
      # @return [true, false] true if file was removed, otherwise false
      def delete_file(id)
        id = self.to_id(id)
        self.grid.get(id)
        grid.delete(id)
      rescue ::Mongo::GridFileNotFound
        false
      end

      protected

      # Reads a content from source - file or filename.
      #
      # @param [File, String] source A filename or file object
      # @return [String] content
      def read_from(source)
        return source.read if source.respond_to?(:read)
        return File.read(source.to_str) if source.respond_to?(:to_str)
        raise ArgumentError
      end

      # Converts given string to BSON::ObjectId.
      #
      # @param [String] id
      # @return [BSON::ObjectId]
      def to_id(id)
        id.kind_of?(BSON::ObjectId) ? id : BSON::ObjectId(id)
      end

    end

  end

end
