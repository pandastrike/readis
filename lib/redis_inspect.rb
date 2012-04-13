#!/usr/bin/env ruby

require 'rubygems'
require 'redis'


class RedisInspector
  def initialize(host, port)
    @redis = Redis.new(:host => host, :port => port)
  end

  def command(input_string)
    parts = input_string.split(" ")
    redis_command = parts.shift

    if redis_command
      redis_command.downcase!
    end

    whitelist = %w(
      exists get hexists hget hgetall hkeys hlen hmget hvals
      lindex llen lrange mget randomkey scard sdiff
      sinter sismember smembers srandmember strlen sunion
      ttl type zcard zcount zrange zrangebyscore zrank
      zrevrange zrevrangebyscore zrevrank zscore
    )

    case redis_command
    when nil
      # do nothing
    when *whitelist
      @redis.send(redis_command, *parts)
    when "exit", "quit"
      exit
    else
      'Unknown Redis command'
    end
  end

  def run
    loop do
      print "readis > "
      input_string = gets.chomp
      begin
        out = command(input_string)
        puts out.inspect
      rescue => error
        puts error.inspect
      end
    end
  end

end


# inspector = RedisInspector.new("127.0.0.1", 6379)
# inspector.command('GET alpha')
# inspector.run

