# Persistence

Persistence is simple & stupid gem that takes care of loading, saving
and materializing objects from persistence backend (MongoDB).

The main idea behind Persistence module is to use pure Ruby
objects that can be persisted and loaded again. This module
acts as a separate layer from your domain objects and it
should hopefully let you focus more on logic of you app and
keep database out of the way (for the most part).


## Initializing Persistence module

Persistence uses only one MongoDB collection to store all objects so
it's necessary to specify database and collection names.

    Persistence.init_persistence(database: 'persistence_database', collection: 'persistence_collection')

Or you can initialize Persistence from YAML file (the first argument is
path to YAML file, the second one is desired environment):

    Persistence.init_from_yml('path/to/config/persistence.yml', 'development')


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


## Identity map

Each persisted object is materialized only once thanks to Persistence Identity Map.
It means Persistence returns one object reference for each persisted document.

    first = Persistence.find('4e649938aabc604f08000001')
    second = Persistence.find('4e649938aabc604f08000001')
    first.equal?(second) # true, false with ActiveRecord


## Copyright

Copyright (c) 2011 Jiri Zajpt, <jz@blueberry.cz>


