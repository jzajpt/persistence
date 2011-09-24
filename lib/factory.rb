# encoding: utf-8

def Factory klass, attributes = {}
  Persistence::Factory.new klass, attributes
end
