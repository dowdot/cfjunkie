require 'optparse'

module CFJunkie
  class Flags

    attr_reader :args
    attr_reader :verbose
    attr_reader :configfile

    def initialize(*args)
      @args     = []
      @verbose  = false

      @options = OptionParser.new do|o|
        o.banner = "Usage: #{File.basename $0} [options] [file|directory...]\n\n"

        o.on("-c", "--config FILE", "Specify the configuration file") do |conf|
          @configfile = conf
        end

        o.on( '--verbose', '-v', 'Speak up' ) do
          @verbose = true
        end

        o.on( '-h', '--help', 'Display this message' ) do
          @help = true
        end
      end

      @args = @options.parse!
      @configfile ||= 'etc/cfjunkie.yaml'
    end

    def help?
      @help
    end
  end
end
