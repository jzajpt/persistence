# Persistence

Persistence is simple & stupid gem that follows data mapper pattern by
introducing a mapper objects that allows you to load, save and find objects
using MongoDB database.

The main idea behind Persistence is to use pure Ruby objects that can be 
persisted and loaded using mapper objects. Mappers acts as a separate 
layer from your domain objects and it should hopefully let you focus 
more on logic of you app and keep database out of the way.


## Initializing Persistence module

+Persistence+ uses instance based approach to initialize the connection. Then you can
register your own mappers:

    persistence = Persistence::Core.new(database: 'persistence_database', collection: 'persistence_collection')
    persistence.register_mapper PersonMapper


## Using mappers to save objects


When mapper saves given objects, it converts object to resource hash (from instance variables). Then
checks to see if it was already persisted or not and finally inserts or updates resource.

Persistence also automatically saves class of object in +_type+ field.

    # Class without #to_resource method
    class Person
      attr_accessor :id
      attr_accessor :name
    end

    p1 = person.new
    p1.name = 'Jonny D'
    PersonMapper.save p1
    # Resource to backend: { _id: '4e649938aabc604f08000001', _type: 'Person', name: 'Jonny D' }
    p p1.id # => BSON::ObjectId('4e649938aabc604f08000001')


## Using mappers to load persisted objects

Based on +_type+ attribute mapper materializes given object with attributes from backend.

    class Book
      attr_accessor :id
      attr_accessor :author
      attr_accessor :title
    end

    # Resource stored in backend: { _id: '4e649938aabc604f08000001', _type: 'Book', author: 'Jonny D' }

    book = PersonMapper.find
    p book.id # => BSON::ObjectId('4e649938aabc604f08000001')
    p book.author # => "Jonny D"


## Copyright

Copyright (c) 2011, 2012 Jiri Zajpt, <jz@blueberry.cz>


