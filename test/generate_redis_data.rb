#!/usr/bin/env ruby

require 'rubygems'
require 'redis'

redis = Redis.new

# puts "This test suite flushes Redis. Are you sure you want to do this?"

redis.flushall

# add some data so we can test

def randstr
  (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
end

for i in 1..100
  redis.set(i, randstr)
end

