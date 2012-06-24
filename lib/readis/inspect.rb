#!/usr/bin/env ruby

require 'rubygems'
require 'redis'


class Readis
  class Inspect < Readis


    def initialize(*args)
      super
      @redis = Redis.new(:host => self.options[:host], :port => self.options[:port])
    end


    def command(input_string)
      parts = input_string.split(" ")
      redis_command = parts.shift
  
      if redis_command
        redis_command.downcase!
      end
  
      whitelist = %w(
        exists get hexists hget hgetall hkeys hlen hmget hvals
        info lindex llen lrange mget randomkey scard sdiff
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
        print "readis #{self.options[:host]}:#{self.options[:port]}>"
        input_string = gets.chomp
        begin
          out = command(input_string)
          case out
          when nil
            # do nothing
          else
            puts out.inspect
          end
        rescue => error
          puts error.inspect
        end
      end
    end
  
  end
end

