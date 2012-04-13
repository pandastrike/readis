#!/usr/bin/env ruby

require 'rubygems'
require 'redis'

# USAGE:
# the user will type something into cli such as ./redis_safe.rb get foo
# the app will get this input, verify it is on the white list, send it to redis, and give the output from redis back to the user


redis = Redis.new

loop do

  print "readis > "
  redis_string = gets.chomp
  parts = redis_string.split(" ")

  # i have an array, the first item should be a redis command

  # !. set
  # ask for an key, enter a key
  # ask for values, enter values

  # this should work exactly like an redis-cli interactive session
  # but it will ONLY allow certain commands

  # TODO test for valid number of arguments
  # TODO make a list of all whitelist commands
  # TODO add the rest of the whitelist commands

  # TODO include ? help functionality
  # TODO possibly list redis ip and port at prompt
  # TODO rspec tests
  # TODO figure out what redis-cli syntax errors are like, mimic redis-cli syntax errors
  # Example: (error) ERR wrong number of arguments for 'hexists' command
  # TODO mimic the way redis formats results
  # TODO find out if any READ-ONLY Redis commands require ONLY numbers
  # TODO make up arrow functionality like BASH history
  # TODO figure out how to use and instlal ruby tab completion library
  # TODO think about case insensitivity 

  command = parts.shift

  case command
  when 'get'
    result = redis.get(parts[0])
  when 'strlen'
    result = redis.strlen(parts[0])
  when 'hgetall'
    result = redis.hgetall(parts[0])
  when 'hkeys'
    result = redis.hkeys(parts[0])
  when 'hlen'
    result = redis.hlen(parts[0])
  when 'hvals'
    result = redis.hvals(parts[0])
  when 'llen'
    result = redis.llen(parts[0])
  when 'scard'
    result = redis.scard(parts[0])
  when 'smembers'
    result = redis.smembers(parts[0])
  when 'srandmember'
    result = redis.srandmember(parts[0])
  when 'zcard'
    result = redis.send(command.to_sym, parts[0])


  # command, 2 arguments
  when 'hexists'
    result = redis.hexists(parts[0], parts[1])
  when 'hget'
    # HGET key field
    if parts.length != 2
      puts "(error) ERR wrong number of arguments for #{command} command"
    else
      result = redis.hget(parts[0], parts[1])
    end
  when 'lindex'
    # LINDEX key index
    result = redis.lindex(parts[0], parts[1])
  when 'sismember'
    # SISMEMBER key member
    result = redis.sismember(parts[0], parts[1])


  # command, 3 arguments
  when 'lrange'
    # LRANGE key start stop
    result = redis.lrange(parts[0], parts[1], parts[2])


  # command, any number of keys
  when 'mget'
    # MGET key [key ...]
    result = redis.mget(*parts)
    # i want to take all elements AFTER the first item in the array 
    # and send those to mget
  when 'sdiff'
    # SDIFF key [key ...]
    result = redis.sdiff(*parts)
  when 'sinter'
    # SINTER key [key ...]
    result = redis.sinter(*parts)
  when 'sunion'
    # SUNION key [key ...]
    result = redis.sunion(*parts)


  # command, key, any number of fields
  when 'hmget'
    # HMGET key field [field ...]
    if parts.length < 2
      puts "(error) ERR wrong number of arguments for #{command} command"
    else
      fields = parts[1..-1]
      result = redis.hmget(parts[0], *fields)
      # i want to take all elements AFTER the first item in the array 
      # and send those to hmget 
    end


  when nil
    next
  when "exit", "quit"
    exit
  else
    # raise ArgumentError, 'Unknown Redis Command'
    puts 'Unknown Redis command'
    next
  end
  puts result.inspect
end
