class Rummy
    attr_accessor :path, :program, :deque, :labels, :aliases, :jump_stack
    attr_accessor :trace_mode, :verbose_mode
    attr_accessor :current, :previous

    def initialize(path, initial_deque: [], verbose_mode: true)
        # Initialize values
        @path = path
        @program, @deque, @labels, @aliases, @jump_stack = [], [], {}, {}, []
        @local_aliases = []
        @trace_mode, @verbose_mode = false, verbose_mode
        @current, @previous = nil, nil
        @contextual_left = false
        @last_deque, @last_jump = -1, nil
        # Set values
        initial_deque.each { |term| push(term, false) }
        load(@path)
    end

    def load(path)
        lines = File.readlines(path)
        @program, @labels = *lex(lines)
    end

    def left?
        unless @contextual_left
            return @current.left?
        else
            return !@current.left?
        end
    end

    def right?
        unless @contextual_left
            return @current.right?
        else
            return !@current.right?
        end
    end

    def peek()
        return if ((@deque == nil) || @deque.empty?)
        word = self.left? ? @deque[0] : @deque[-1]
    #   puts "peek() => #{word.inspect}"
        return word
    end

    def pop(n = 1)
        words = []
        if @deque.length < n
            print_error('No value to pop from deque')
            exit
        end
        return if ((@deque == nil) || @deque.empty?)
        (0...n).each do
            words << (self.left? ? @deque[0] : @deque[-1])
            @deque = self.left? ? @deque[1..-1] : @deque[0..-2]
        end
    #   puts "pop() => #{words.inspect}"
        return words.length == 1 ? words.first : words.flatten
    end

    def push(word, left = self.left?)
        word = self.alias(word)
        word = true if word == 'true'
        word = false if word == 'false'
        word = word.to_f if (word.is_a?(String) && word.float?)
        if @deque == nil
            @deque = []
        else
            @deque = (left ? [word] + @deque : @deque + [word]).flatten
        end
    end

    def trace(ip = nil, instruction = @previous)
        return if instruction == nil
        instruction = "#{instruction.ljust(16, ' ')}=> #{@deque.inspect}".colorize(:italics)
        puts "#{(ip.to_s + ':').colorize(:grey)} #{instruction} (#{@local_aliases})"
    end

    def clear
        @deque = []
    end

    def alias(word)
        if @aliases.key?(word)
            return @aliases[word]
        else
            @local_aliases.reverse.each { |a| return a[word] if a.key?(word) }
            return word
        end
    end

    def label(word)
        if @labels.key?(word)
            return @labels[word]
        else
            print_error("Unaddressable label '#{word}'")
            exit
        end
    end

    def print_program
        @program.each_with_index { |word, index| puts "#{index}: #{word}" }
    end

    def run_program(path, verbose, param_count)
        arr = []
        (0...param_count).each { arr << pop() }
        rummy = Rummy.new(path, :initial_deque => arr, :verbose_mode => verbose)
        return rummy.interpret
    end

    def include_program(path, ip)
        unless File.file?(path)
            path = "./modules/#{path}.rummy"
            unless File.file?(path)
                print_error("Invalid file path '#{path}'")
                return
            end
        end
        lines = File.readlines(path)
        program, labels = *lex(lines)
        @program.insert(ip + 1, program).flatten!
        for name, index in labels do
            @labels[name] = index + ip
        end
        @jump_stack << ip + program.length - 1
    end
end