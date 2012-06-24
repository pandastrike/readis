class Readis
  class Inspect < Readis

    WHITELIST = %w[
      keys
      exists get hexists hget hgetall hkeys hlen hmget hvals
      info lindex llen lrange mget randomkey scard sdiff
      sinter sismember smembers srandmember strlen sunion
      ttl type zcard zcount zrange zrangebyscore zrank
      zrevrange zrevrangebyscore zrevrank zscore
    ]

    def initialize(*args)
      super
      @redis = Redis.new(:host => self.options[:host], :port => self.options[:port])
    end

    def parser
      optparser = super
      optparser.banner = <<-BANNER

Usage: readis inspect [options]

      BANNER
      optparser
    end

    def run
      loop do
        print "readis #{self.options[:host]}:#{self.options[:port]}> "
        input_string = gets.chomp
        # TODO: tab completion.  Example implementation in automatthew/flipper
        # https://github.com/automatthew/flipper/blob/master/lib/flipper.rb
        # Inititally, we should only try to complete using the list of command
        # names, but we may later consider adding keys, fields, member names, etc.
        # discovered through commands issued.
        begin
          out = execute_command(input_string)
          case out
          when nil
            # do nothing
          else
            # TODO: consider the formatting.  Do we want to mimic
            # the redis-cli output?
            puts out.inspect
          end
        rescue => error
          puts "Error: #{error.message}"
        end
      end
    end
  
    def execute_command(input_string)
      parts = input_string.split(" ")
      redis_command = parts.shift
  
      if redis_command
        redis_command.downcase!
      end
  
      case redis_command
      when nil
        # do nothing
      when *WHITELIST
        @redis.send(redis_command, *parts)
      when "exit", "quit"
        exit
      else
        raise ArgumentError, "Unknown or unsupported command"
      end
    end

  end
end

