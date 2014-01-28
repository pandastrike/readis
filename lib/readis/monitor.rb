class Readis
  class Monitor < Readis

    def initialize(*args)
      super
      if options[:includes] && options[:excludes]
        raise ArgumentError, "Define either --includes or --excludes, but not both."
      end
    end

    def run
      @redis.monitor do |line|
        if formatted = format(line)
          puts formatted
        end
      end
    end

    def options
      @options ||= super.merge(
        :colorized => false
      )
    end

    def parser
      optparser = super
      optparser.banner = <<-BANNER

Usage: readis monitor [options]

      BANNER
      optparser.on("-c", "--color", "enable syntax coloring") do |color|
        options[:colorized] = true
      end
      optparser.on("-i", "--include COMMANDS",
        "comma separated list of Redis commands to include") do |includes|
        options[:includes] = includes.split(",").map {|c| c.upcase}
      end
      optparser.on("-e", "--exclude COMMANDS",
        "comma separated list of Redis commands to exclude") do |excludes|
        options[:excludes] = excludes.split(",").map {|c| c.upcase}
      end
      # TODO: options for
      # * compact vs. spacey
      # * timestamp on/off
      optparser
    end

    def format(line)
      if timestamp = line.slice!(/^[\d.]+ /)
        timestamp.strip!
      end
      if client = line.slice!(/\[\d+ [\d:\.]+\] "/)
        client = client.slice(3..-4)
      end
      parts = line.split('" "').map {|p| p.chomp('"') }

      command = parts[0].upcase
      return if filtered?(command)

      out = [ format_command(command) ]

      one_channel_one_message = %w(PUBLISH)
      one_key_one_value = %w(APPEND GETSET LPUSHX RPUSHX SET SETNX)
      one_key_one_argument = %w(DECRBY EXPIRE EXPIREAT GETBIT INCRBY LINDEX MOVE RENAME RENAMENX)
      one_key_one_field = %w(HEXISTS HGET)
      one_key_one_field_one_value = %w(HSET HSETNX)

      # TODO: add the rest of the redis commands
      case command
      when *one_channel_one_message
        # one channel, one message
        out << format_channel(parts[1])
        out << format_message(parts[2])
      when *one_key_one_value
        # one key, one value
        out << format_key(parts[1])
        out << format_value(parts[2])
      when *one_key_one_argument
        # one key, one arg
        out << format_key(parts[1])
        out << format_argument(parts[2])
      when "BLPOP"
        # variable number of keys, last part is an arg
        parts.slice(1..-2).each do |part|
          out << format_key(part)
        end
        out << format_argument(parts[-1])
      when "LPUSH", "RPUSH", "ZREM"
        # one key, rest are values
        out << format_key(parts[1])
        parts.slice(2..-1).each do |part|
          out << format_value(part)
        end
      when "ZRANGE", "ZRANGEBYSCORE", "ZREMRANGEBYSCORE",
        "ZREMRANGEBYRANK", "ZCOUNT", "ZREVRANK", "ZREVRANGE"
        # one key, rest are arguments
        out << format_key(parts[1])
        parts.slice(2..-1).each do |part|
          out << format_argument(part)
        end
      when "HMSET"
        # key, field, value, [field, value, ...]
        out << format_key(parts[1])
        out << "\n" + format_field(parts[2])
        out << format_value(parts[3])
        parts.slice(4..-1).each_slice(2) do |a|
          out << "\n" + format_field(a[0])
          out << format_value(a[1])
        end
      when *one_key_one_field_one_value
        # key, field, value
        out << format_key(parts[1])
        out << format_field(parts[2])
        out << format_value(parts[3])
      when *one_key_one_field
        # key, field
        out << format_key(parts[1])
        out << format_field(parts[2])
      when "ZADD", "ZINCRBY"
        # ZADD score member [score] [member]
        out << format_key(parts[1])
        parts.slice(2..-1).each_slice(2) do |pair|
          out << format_argument(pair.first)
          out << format_value(pair.last)
        end
      else
        # all keys
        if rest = parts.slice(1..-1)
          parts.slice(1..-1).each do |part|
            out << format_key(part)
          end
        end
      end
      "#{colorize(:underscore, timestamp)} #{out.join('')}"
    end

    # Wraps the command in the appropriate ANSI color codes
    def format_command(string)
      case string
      when "MULTI", "EXEC", "WATCH"
        colorize(:red, string + " ")

      when /SUBSCRIBE/, "PUBLISH"
        colorize(:yellow, string + " ")
      else
        colorize(:green, string + " ")
      end
    end

    def format_channel(string)
      colorize(:cyan, string + " ")
    end

    def format_key(string)
      colorize(:cyan, string + " ")
    end

    def format_argument(string)
      colorize(:magenta, string + " ")
    end

    def format_field(string)
      colorize(:blue, string + " ")
    end

    def format_message(string)
      begin
        string.gsub!(/\\/, "")
        object = JSON.parse(string)
        out = "\n" + JSON.pretty_generate(object)
      rescue
        out = string + " "
      end
      out
    end

    def format_value(string)
      begin
        string.gsub!(/\\/, "")
        object = JSON.parse(string)
        out = "\n" + JSON.pretty_generate(object)
      rescue
        out = string + " "
      end
      out
    end

    def filtered?(command)
      if list = @options[:includes]
        !list.include?(command)
      elsif list = @options[:excludes]
        list.include?(command)
      end
    end

    def colorize(name, string)
      if @options[:colorized]
        [Term::ANSIColor.send(name), string, Term::ANSIColor.reset].join
      else
        string
      end
    end



  end
end
