require 'pp'
require 'yaml'
require 'net/ssh'

module CFJunkie
  class Runner

    attr_reader :flags

    def initialize(flags)
      @flags = flags
      @verbose = flags.verbose
      @gitopts = '-q' unless @verbose

      loadconf
      preflight
    end

    def speak (msg)
      puts "==> " + msg if @verbose
    end

    def preflight
      # ensure the storage directory exists
      Dir.mkdir(@config[:storage], 0700) unless File.directory?(@config[:storage])
      fullpath = @config[:storage] + @config[:path]

      unless File.directory?(@config[:storage] + '/.git')
      # Ensure the storage location is a git repo
        speak "Cloning source repo..."
        %x{git clone #{@gitopts} #{@config[:gitrepo]} #{@config[:storage]}}
      else
      # Fetch and reset the directory to match that of remote
        Dir.chdir(@config[:storage])
        speak "Forcibly resetting to orign"
        %x{git fetch #{@gitopts} origin; git reset --hard origin/master}
      end

      speak "Switching to #{fullpath}"
      Dir.chdir(fullpath)
      exit 1 unless Dir.pwd == fullpath
    end

    def retrieve_cisco_config

    end

    def retrieve_juniper_config

    end

    def run

      # variables for munging passwords out of configs
      regex = /\r\n/
      newstring = "\n"

      # Get each switch configuration
      @config[:switchgroups].each do |g,devices|
        speak "Processing switchgroup #{g}"
        devices.each do |d|
          speak "Connecting to switch #{d}"
          begin
            Net::SSH.start(d, @config[:username], :password => @config[:password], :keys => @config[:keys]) do |ssh|
              speak "  Retrieving configuration"
              case g
              when :cisco
                show_cmd = "show startup"
              when :juniper
                show_cmd = "show configuration | no-more"
              when :ucs
                show_cmd = "show configuration"
              end
              output = ssh.exec!(show_cmd)

              if output
                speak "  Munging output data"
                output.gsub!( /\r\n/, "\n" )
                output.gsub!( /\$1.+$/, "sneakybeast" )
              else
                puts "ERROR: no output received"
                next
              end

              filename = d + '.conf'
              message  = "Auto-commit configuration: #{d}"

              speak "writing the configiration to disk"
              File.open(filename, 'w') {|f| f.write(output) }

              speak "commiting the updates"
              %x{git add #{filename}; git commit -m '#{message}'}
            end
          rescue Net::SSH::AuthenticationFailed => e
            puts "ERROR: Unable to authenticate to switch #{d}: #{e}"
          rescue Errno::ETIMEDOUT => e
            puts "ERROR: Timeout connecting to switch #{d}: #{e}"
          rescue => e
            puts "ERROR: #{e}"
          end
          speak "Pushing to master"
          %x{git push #{@gitopts} origin master}
        end
      end
      speak "Done!"

    end

    #
    # Load the configuration file
    #
    def loadconf
      @config = YAML::load(File.read(@flags.configfile))
      @config
    end

  end
end
