State = Struct.new(:path, :program, :deque, :labels, :aliases, :trace_mode, :jump_stack, :current, :previous) do
    def left?
        return self.current.left?
    end

    def right?
        return self.current.right?
    end

    def clear
        self.deque = []
    end

    def alias(word)
        if self.aliases.key?(word)
            return self.aliases[word]
        else
            return word
        end
    end

    def label(word)
        if self.labels.key?(word)
            return self.labels[word]
        else
            puts "rummy_error: Unaddressable label '#{word}'".colorize(:red)
            exit
        end
    end

    def include_program(path, index)
        if File.file?(path)
            program, labels = *lex(File.readlines(path))
            self.program.insert(index + 1, program).flatten!
            self.labels.merge!(labels)
        else
            puts "rummy_error: Invalid file path '#{path}'".colorize(:red)
        end
    end
end

def pop(n = 1)
    words = []
    (0...n).each do
        words << ($state.left? ? $state.deque[0] : $state.deque[-1])
        $state.deque = $state.left? ? $state.deque[1..-1] : $state.deque[0..-2]
    end
    return words.length == 1 ? words.first : words.flatten
end

def push(word, left = $state.left?)
    word = $state.alias(word)
    word = true if word == 'true'
    word = false if word == 'false'
    word = word.to_i if (word.is_a?(String) && word.float?)
    $state.deque = (left ? [word] + $state.deque : $state.deque + [word]).flatten
end

def trace(instruction = $state.previous)
    puts "#{instruction}\t=> #{$state.deque.inspect}"
end