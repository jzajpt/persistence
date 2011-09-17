# encoding: utf-8

require 'mongo'
require 'bson'

require 'persistence/version'
require 'persistence/base'
require 'persistence/load'
require 'persistence/save'
require 'persistence/destroy'
require 'persistence/files'

if defined?(Rack)
  require 'rack/persistence/identity_map'
end


module Persistence

  extend Base
  extend Load
  extend Save
  extend Destroy
  extend Files

end
