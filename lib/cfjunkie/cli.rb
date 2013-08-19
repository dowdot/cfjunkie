require 'cfjunkie/flags'
require 'cfjunkie/runner'

module CFJunkie
  class CLI

    attr_reader :flags
    attr_reader :runner

    def initialize(flags)
      @flags  = flags
      @runner = CFJunkie::Runner.new(@flags)
    end

    def run
      if flags.help?
        puts flags
        exit
      end

      runner.run
    end

    def self.shutdown
      puts "Terminating..."
      exit 0
    end

    Signal.trap("TERM") do
      shutdown()
    end

    Signal.trap("INT") do
      shutdown()
    end

    def self.run(*args)
      flags = CFJunkie::Flags.new args
      data = CFJunkie::CLI.new(flags).run
      #CFJunkie::Util.report(data)
    end

  end
end
