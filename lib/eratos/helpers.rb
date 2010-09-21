module Eratos
  module Helpers
    def warn(*args)
      $stderr.puts(args * " ")
    end
    
    def debug(*args)
      warn(*args) if Eratos.options[:verbose]
    end
    
    def die(msg)
      warn("Error: #{msg}.")
      exit 1
    end
  end
end
