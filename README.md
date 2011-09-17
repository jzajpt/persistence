# Persistence

Persistence is simple & stupid gem that takes care of loading, saving
and materializing objects from persistence backend (MongoDB).

The main idea behind Persistence module is to use pure Ruby
objects that can be persisted using this Persistence module.


## Initializing Persistence module

Persistence uses only one collection to store objects.

    Persistence.init_persistence(database: 'persistence_database', collection: 'persistence_collection')


## Using Persistence to save objects

When Persistence saves given objects, it converts object to resource hash (from
instance variables or calling `#to_resource` method if object defines one). Then
checks to see if it was already persisted or not and finally inserts or updates resource.


Persistence also automatically saves class of object in `_type` field (so you don't
have to provide it # in `#to_resource` method).


    # Class without #to_resource method
    class Person
      attr_accessor :id
      attr_accessor :name
    end

    p1 = person.new
    p1.name = 'Jonny D'
    Persistence.save p1
    # Resource to backend: { _id: '4e649938aabc604f08000001', _type: 'Person', name: 'Jonny D' }
    p p1.id # => BSON::ObjectId('4e649938aabc604f08000001')

## Using Persistence to load persisted objects

Based on `_type` attribute Persistence materializes given object with attributes
from backend.

    class Book
      attr_accessor :id
      attr_accessor :author
      attr_accessor :title
    end

    # Resource stored in backend: { _id: '4e649938aabc604f08000001', _type: 'Book', author: 'Jonny D' }

    book = Persistence.find
    p book.id # => BSON::ObjectId('4e649938aabc604f08000001')
    p book.author # => "Jonny D"


## Copyright


Copyright (c) 2011 Jiri Zajpt, <jz@blueberry.cz>


