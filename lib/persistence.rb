# encoding: utf-8

require 'mongo'
require 'bson'

require 'persistence/boolean'
require 'persistence/version'
require 'persistence/object_factory'
require 'persistence/mapper'
require 'persistence/core'

# Persistence is simple & stupid gem that follows data mapper pattern by
# introducing a mapper objects that allows you to load, save and find objects
# using MongoDB database.
#
# The main idea behind +Persistence+ is to use clean & pure Ruby
# objects that can be persisted using mappers.
#
# == Initializing connection
#
# +Persistence+ uses instance based approach to initialize the connection. Then you can
# register your own mappers:
#
#    persistence = Persistence::Core.new(database: 'persistence_database', collection: 'persistence_collection')
#    persistence.register_mapper PersonMapper
#
#
# == Mappers
#
# Mapper is a layer that moves data between database and your domain logic, it allows
# you to cleanly separate the persistence logic from your business logic.
#
#     class PersonMapper < Persistence::Mapper
#     end
#
#
# == Using mappers to save objects
#
# When mapper saves given objects, it converts object to resource hash (from instance variables). Then
# checks to see if it was already persisted or not and finally inserts or updates resource.
#
# Persistence also automatically saves class of object in +_type+ field.
#
#    # Class without #to_resource method
#    class Person
#      attr_accessor :id
#      attr_accessor :name
#    end
#
#    p1 = person.new
#    p1.name = 'Jonny D'
#    PersonMapper.save p1
#    # Resource to backend: { _id: '4e649938aabc604f08000001', _type: 'Person', name: 'Jonny D' }
#    p p1.id # => BSON::ObjectId('4e649938aabc604f08000001')
#
#
# == Using mappers to load persisted objects
#
# Based on +_type+ attribute mapper materializes given object with attributes from backend.
#
#    class Book
#      attr_accessor :id
#      attr_accessor :author
#      attr_accessor :title
#    end
#
#    # Resource stored in backend: { _id: '4e649938aabc604f08000001', _type: 'Book', author: 'Jonny D' }
#
#    book = PersonMapper.find
#    p book.id # => BSON::ObjectId('4e649938aabc604f08000001')
#    p book.author # => "Jonny D"
#
#
# @author Jiri Zajpt
module Persistence
end
