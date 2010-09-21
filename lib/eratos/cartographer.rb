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
        Option.options[name.downcase].to_arg(value)
      end.compact.join(" ")
    end
    
    def render!
      # do the deed
    end
  end
end
