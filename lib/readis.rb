require "optparse"

require "rubygems"

class Readis 

  def self.command(name)
    case name
    when "inspect"
      Readis::Inspect.new
    when "monitor"
      Readis::Monitor.new
    else
      puts "Usage: readis <command> [options]"
      puts "Available commands: inspect, monitor"
      exit
    end
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

  def initialize
    self.parser.parse!
    @host = options[:host]
    @port = options[:port]
  end

end


require "readis/inspect"
# require "readis/monitor"

