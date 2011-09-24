# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "persistence/version"

Gem::Specification.new do |s|
  s.name        = "Persistence"
  s.version     = Persistence::VERSION
  s.authors     = ["Jiří Zajpt"]
  s.email       = ["jzajpt@blueberry.cz"]
  s.homepage    = ""
  s.summary     = %q{Persistence layer gem}
  s.description = %q{}

  s.rubyforge_project = "persistence"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "mongo"
  s.add_dependency "bson_ext"
  s.add_dependency "i18n"
  s.add_dependency 'mime-types'
  s.add_dependency "activesupport", ">= 3.1.0"
  s.add_development_dependency "fabrication"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "rake", "~> 0.9.0"
  s.add_development_dependency "rack"
end
