require "rubygems"
require "trollop"

module Eratos
  class << self
    attr_accessor :blocks, :config, :options
    
    def boot!
      load_options
      load_config
      load_blocks
    end
    
    def start!
      
    end
    
    protected
      def load_options
        self.options = Trollop.options do
          opt :config, "Path to Eratos config file", :type => :string, :required => true
          opt :map,    "Render specific map(s)", :type => :strings
        end
      end
      
      def load_config
        config_path = File.expand_path(options[:config])
        self.config = YAML.load_file(config_path)
      rescue Errno::ENOENT
        Trollop.die "couldn't find Eratos config file at #{config_path}"
      rescue ArgumentError => e
        Trollop.die "couldn't parse Eratos config file: #{e.message}"
      end
      
      def load_blocks
        blocks_path = File.join(File.dirname(__FILE__), "blocks.yml")
        self.blocks = YAML.load_file(blocks_path)
      end
  end
end
