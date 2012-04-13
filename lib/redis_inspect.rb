#!/usr/bin/env ruby

require 'rubygems'
require 'redis'

$redis = Redis.new

def smurf(input_string)
  parts = input_string.split(" ")
  command = parts.shift

  whitelist = %w(
    get strlen hgetall hkeys hlen hvals llen scard
    smembers srandmember zcard hexists hget lindex sismember lrange
    mget sdiff sinter sunion hmget
  )

  case command
  when nil
    # do nothing
  when *whitelist
    result = $redis.send(command.to_sym, *parts)
    puts result.inspect
  when "exit", "quit"
    exit
  else
    # raise ArgumentError, 'Unknown Redis Command'
    puts 'Unknown Redis command'
  end
end


loop do
  print "readis > "
  input_string = gets.chomp

  smurf(input_string)
end
