module Eratos
  module Helpers
    def warn(*args)
      $stderr.puts(args * " ") unless Eratos.options[:silent]
    end
    
    def status(*args)
      $stderr.print(args * " ") unless Eratos.options[:silent]
    end
    
    def debug(*args)
      warn(*args) if Eratos.options[:verbose]
    end
    
    def tab(num=1)
      ("  " * num)[0..-2]
    end
    
    def die(msg)
      warn("Error: #{msg}.")
      exit 1
    end
  end
end
