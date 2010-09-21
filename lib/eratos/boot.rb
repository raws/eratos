require "eratos/helpers"
require "rubygems"
require "trollop"

module Eratos
  class << self
    include Helpers
    attr_accessor :blocks, :config, :options
    
    def boot!
      load_options
      load_config
      load_blocks
    end
    
    def start!
      maps.each do |name, options|
        Cartographer.new(name, options).render!
      end
    end
    
    def maps
      config["maps"]
    end
    
    protected
      def load_options
        self.options = Trollop.options do
          opt :config,  "Path to Eratos config file", :type => :string, :required => true
          opt :map,     "Render specific map(s)", :type => :strings
          opt :silent,  "Don't print anything", :type => :boolean
          opt :verbose, "Print debug information", :type => :boolean
        end
      end
      
      def load_config
        config_path = File.expand_path(options[:config])
        self.config = YAML.load_file(config_path)
      rescue Errno::ENOENT
        die "couldn't find Eratos config file at #{config_path}"
      rescue ArgumentError => e
        die "couldn't parse Eratos config file: #{e.message}"
      end
      
      def load_blocks
        blocks_path = File.join(File.dirname(__FILE__), "blocks.yml")
        self.blocks = YAML.load_file(blocks_path)
      end
  end
end

Eratos.boot!
require "eratos"
