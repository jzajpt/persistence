# encoding: utf-8

require 'mongo'
require 'bson'

require 'persistence/version'
require 'persistence/base'
require 'persistence/load'
require 'persistence/save'
require 'persistence/destroy'
require 'persistence/files'


module Persistence

  extend Base
  extend Load
  extend Save
  extend Destroy
  extend Files

end
