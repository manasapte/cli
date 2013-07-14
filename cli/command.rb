module CLI
  class Command
    def initialize(usage, options, handler)
      parts    = usage.split(/\s+/)
      @name    = parts.shift
      usage    = parts.join(" ")
      @handler = handler.to_proc
      @options = {}
      @opts    = OptionParser.new

      @opts.program_name = @name

      @opts.banner = "Usage: #{@name} #{usage}"

      options.each do |name, opts|
        @opts.on(*opts) do |v|
          @options[name] = v
        end
      end

      @opts.base.append("", nil, nil)
      @opts.base.append("Additional options:", nil, nil)

      @opts.on_tail("-h", "--help", "Show this message") { print_help }
    end

    def run(argv)
      $0 = "#{@name} #{argv.join(" ")}"
      @handler.call(@options, @opts.permute!(argv))
    rescue OptionParser::InvalidOption => e
      @opts.warn(e.message)
      print_help
    rescue Interrupt
      exit 0
    rescue => e
      @opts.abort(e.message)
    end

    def to_proc
      proc { |opts, args| run(args) }
    end

    private

    def print_help
      puts @opts
      exit 1
    end
  end
end
