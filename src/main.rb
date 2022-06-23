class Rummy
    attr_accessor :path, :program, :deque, :labels, :aliases, :jump_stack
    attr_accessor :trace_mode, :verbose_mode
    attr_accessor :current, :previous

    def initialize(path, initial_deque: [], verbose_mode: true)
        # Initialize values
        @path = path
        @program, @deque, @labels, @aliases, @jump_stack = [], [], {}, {}, []
        @trace_mode, @verbose_mode = false, verbose_mode
        @current, @previous = nil, nil
        # Set values
        initial_deque.each { |term| push(term, false) }
        load(@path)
    end

    def load(path)
        lines = File.readlines(path)
        @program, @labels = *lex(lines)
    end

    def left?
        return @current.left?
    end

    def right?
        return @current.right?
    end

    def pop(n = 1)
        words = []
        (0...n).each do
            words << (self.left? ? @deque[0] : @deque[-1])
            @deque = self.left? ? @deque[1..-1] : @deque[0..-2]
        end
        return words.length == 1 ? words.first : words.flatten
    end

    def push(word, left = self.left?)
        word = self.alias(word)
        word = true if word == 'true'
        word = false if word == 'false'
        word = word.to_i if (word.is_a?(String) && word.float?)
        @deque = (left ? [word] + @deque : @deque + [word]).flatten
    end

    def trace(instruction = @previous)
        puts "#{instruction}\t=> #{@deque.inspect}"
    end

    def clear
        @deque = []
    end

    def alias(word)
        return @aliases.key?(word) ? @aliases[word] : word
    end

    def label(word)
        if @labels.key?(word)
            return @labels[word]
        else
            puts "rummy_error: Unaddressable label '#{word}'".colorize(:red)
            exit
        end
    end

    def run_program(path, verbose, param_count)
        arr = []
        (0...param_count).each { arr << pop() }
        rummy = Rummy.new(path, :initial_deque => arr, :verbose_mode => verbose)
        return rummy.interpret
    end

    def include_program(path, index)
        if File.file?(path)
            lines = File.readlines(lines)
            program, labels = *lex(file)
            @program.insert(index + 1, program).flatten!
            @labels.merge!(labels)
        else
            puts "rummy_error: Invalid file path '#{path}'".colorize(:red)
        end
    end
end