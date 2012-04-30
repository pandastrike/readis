#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), './../lib/', 'redis_inspect')
require 'rubygems'
require 'redis'

redis = Redis.new

# puts "This test suite flushes Redis. Are you sure you want to do this?"

redis.flushall

# add some data so we can test

redis.set("smurf", "blue")
redis.mset("alpha", "alphas", "bravo", "bravos")









inspector = RedisInspector.new("127.0.0.1", 6379)

test_message = "get an existing key returns value"
result = inspector.command("get smurf")
unless result == "blue"
  puts result.inspect
  raise "OOPS"
end
puts test_message

test_message = "get a nonexistent key returns nil"
result = inspector.command("get doesnotexist")
unless result == nil
  puts result.inspect
  raise "OOPS"
end
puts test_message

test_message = "get too many commands raises an exception"
begin
  inspector.command("get too many commands")
  raise "We should never get here"
rescue => error
  unless error.message =~ /wrong number of arguments/ 
    puts error.message
    raise "FAILED: #{test_message}"
  end
end
puts test_message

test_message = "mget two keys returns 2 values"
result = inspector.command("mget alpha bravo")
unless result == ["alphas", "bravos"]
  puts result.inspect
  raise "OOPS"
end
puts test_message

test_message = "mget an existing key and a nonexistent key returns an existing key and nil"
result = inspector.command("mget alpha zebra")
unless result == ["alphas", nil]
  puts result.inspect
  raise "OOPS"
end
puts test_message

