$:.push File.expand_path("../lib", __FILE__)

require "s3_relay/version"

Gem::Specification.new do |s|
  s.name        = "mongoid_direct_s3_upload"
  s.version     = S3Relay::VERSION
  s.authors     = ["hartator"]
  s.email       = "hartator@gmail.com"
  s.homepage    = "http://github.com/kjohnston/mongoid-direct-s3-upload"
  s.summary     = "Rails and Mongoid simplest helpers possible to directly upload file to S3 without hitting the server."
  s.description = "Rails and Mongoid simplest helpers possible to directly upload file to S3 without hitting the server. Support concurrent uploads, progress bars, and more."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_runtime_dependency "coffee-rails"
  s.add_runtime_dependency "rails", ">= 5.1"
  s.add_runtime_dependency "addressable", ">= 2.3.8" # URI.encode replacement

  s.add_development_dependency "guard-minitest", "~> 2.4",  ">= 2.4.6"
  s.add_development_dependency "minitest-rails", "~> 3.0.0", ">= 3.0.0"
  s.add_development_dependency "mocha",          "~> 1.2",  ">= 1.2.1"
  s.add_development_dependency "pg",             "~> 0.21", ">= 0.21.0"
  s.add_development_dependency "simplecov",      "~> 0.14",  ">= 0.14.1"
  s.add_development_dependency "thor"  # Bundler requirement
end