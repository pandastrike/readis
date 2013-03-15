require "optparse"

require "rubygems"
require "redis"
require "json"
require "term/ansicolor"

class Readis 

  class Retry
    def initialize(client)
      @client = client
      @backoff = 1
    end

    def method_missing(name, *args, &block)
      begin
        @client.send(name, *args, &block)
      rescue => e
        puts "Command failed because of error: #{e.message}"
        puts "Sleeping #{@backoff} seconds"
        sleep @backoff
        if @backoff <= 8
          @backoff = @backoff * 2
        end
        @backoff = 1 if alive?
        retry
      end
    end

    def alive?
      begin
        @client.ping
      rescue
        false
      end
    end

    def type(*args)
      @client.send(:type, *args)
    end

  end

  def self.command_runner(name)
    case name
    when "inspect"
      Readis::Inspect.new
    when "monitor"
      Readis::Monitor.new
    else
      puts "Usage: readis <command> [options]"
      puts "Usage: readis help <command>"
      puts "Available commands: inspect, monitor"
      exit
    end
  end

  def initialize
    self.parser.parse!
    @_redis = Redis.new(:host => self.options[:host], :port => self.options[:port])
    @redis = Retry.new(@_redis)
  end

  def options
    @options ||= {
      :host => "127.0.0.1",
      :port => "6379",
    }
  end

  def parser
    OptionParser.new do |parser|
      parser.on("-h", "--host=HOST",
        "redis host. Defaults to '127.0.0.1'") do |name|
        self.options[:host] = name
      end
      parser.on("-p", "--port=PORT",
        "redis port. Defaults to '6379'") do |name|
        self.options[:port] = name
      end
    end
  end

  def help
    parser.help
  end

end


require "readis/inspect"
require "readis/monitor"

