module Eratos
  class Cartographer
    include Helpers
    attr_reader :name, :options
    
    def initialize(name, options)
      @name = name
      @options = options
    end
    
    def arguments
      options.map do |name, value|
        name = name.downcase
        Option.options[name].to_arg(value) if Option.options.key?(name)
      end.compact.join(" ")
    end
    
    def command
      "#{Cartographer.binary} #{arguments}"
    end
    
    def render!
      warn %{Generating map "#{name}"...}
      
      options["binary"] = true
      debug tab, command
      
      open("| #{command}") do |io|
        warn tab, "Preparing..."
        state, complete = 0, 0
        until io.eof?
          status = io.getc
          if status != state
            state = status
            case state
            when STATUS_RENDERING
              status tab, "Rendering... "
            when STATUS_COMPOSITING
              status "\n  Compositing... "
            when STATUS_SAVING
              status "\n  Saving... "
            when STATUS_ERROR
              warn "\n Error: #{io.read}"
              return
            end
          end
          
          progress = ((io.getc.to_i * 100) / 0xff) + 1
          if progress > complete
            complete = progress
            status "#{progress}% " if progress % 25 == 0
          end
        end
        warn "\n  Done!"
      end
    end
    
    class << self
      def binary
        if Eratos.config["settings"] && Eratos.config["settings"]["c10t"]
          File.expand_path(Eratos.config["settings"]["c10t"])
        elsif (path = `which c10t`) && $?.success?
          path.strip
        else
          "c10t"
        end
      end
    end
    
    STATUS_RENDERING = 0x10
    STATUS_COMPOSITING = 0x20
    STATUS_SAVING = 0x30
    STATUS_ERROR = 0x01
  end
end
