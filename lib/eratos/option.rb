require "shellwords"

module Eratos
  class Option
    include Helpers
    attr_accessor :name, :equivalent, :options, :block
    
    def initialize(name, equivalent, options={}, &block)
      @name = name
      @equivalent = equivalent
      @options = options
      @block = block
    end
    
    def to_arg(value)
      value = block.call(value, self) || value if block?
      case type
      when :boolean then switch if value
      when :string
        "#{switch} #{escape? ? value.to_s.shellescape : value}"
      when :array
        "#{switch} " + value.compact.map do |v|
          escape? ? v.to_s.shellescape : v
        end.join(" #{switch} ")
      end
    end
    
    def type
      options[:type] || :string
    end
    
    def switch
      (equivalent.length > 1 ? "--" : "-") + equivalent.gsub("_", "-")
    end
    
    def block?
      !block.nil?
    end
    
    def escape?
      options.fetch(:escape, true)
    end
    
    class << self
      include Helpers
      attr_accessor :options
      
      private
        def option(name, equivalent, options={}, &block)
          name, equivalent = name.to_s, equivalent.to_s
          self.options ||= {}
          self.options[name] = Option.new(name, equivalent, options, &block)
        end
    end
    
    expand_path = Proc.new do |path,|
      if path.is_a?(Hash)
        folder, file = path["folder"], path["file"]
        File.expand_path(File.join(folder, file))
      else
        File.expand_path(path)
      end
    end
    option :world, :w, {}, &expand_path
    option :output, :o, {}, &expand_path
    
    option :include, :i, :type => :array do |blocks,|
      blocks.map { |b| b.is_a?(String) ? Eratos.blocks[b] : b }
    end
    option :exclude, :e, :type => :array do |blocks, option|
      if blocks.is_a?(String) && blocks =~ /all/i
        option.options[:type] = :string
        option.options[:escape] = false
        "0 -a" # Exclude air (no effect), sneak in --hide-all switch
      else
        blocks.map { |b| Eratos.blocks[b] if b.is_a?(String) }
      end
    end
    
    option :oblique, :q, :type => :boolean
    option :isometric, :y, :type => :boolean
    option :rotate, :f do |angle,|
      unless [90, 180, 270].include?(angle.to_i)
        die "rotate option angle must be 90, 180 or 270 degrees"
      end; angle
    end
    
    option :night, :n, :type => :boolean
    option :caves, :c, :type => :boolean
    option :top, :t
    option :bottom, :b
    option :crop, :L do |crop, option|
      %w(north south west east).map { |d| crop[d] }.join(",") if crop.is_a?(Hash)
    end
    
    option :silent, :s, :type => :boolean
    option :no_check, :N, :type => :boolean
    option :verify_chunks, :require_all, :type => :boolean
    option :binary, :x, :type => :boolean
    option :threads, :m
    option :memory, :M
    option :cache, :C
  end
end
