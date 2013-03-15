Gem::Specification.new do |s|
  s.name = "readis"
  s.version = "0.2.2"
  s.authors = ["Matthew King", "Lance Lakey"]
  s.homepage = "https://github.com/lancelakey/readis"
  s.summary = "Read-only Redis Utilities"

  s.files = Dir["{lib,bin}/**/*.rb"] + %w[LICENSE Readme.md]
  s.require_path = "lib"
  s.executables = ["readis"]

  s.add_dependency("redis", ">= 2.2.2")
  s.add_dependency("json", ">= 1.0")
  s.add_dependency("term-ansicolor", ">= 1.0")
  s.add_development_dependency("starter", ">=0.1.6")
end
