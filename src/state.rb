State = Struct.new(:path, :program, :deque, :labels, :trace_mode, :jump_stack, :current, :previous) do
    def left?
        return self.current.left?
    end

    def right?
        return self.current.right?
    end

    def clear
        self.deque = []
    end

    def label(word)
        if self.labels.key?(word)
            return self.labels[word]
        else
            puts "rummy_error: Unaddressable label '#{word}'".colorize(:red)
            exit
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
    word = true if word == 'true'
    word = false if word == 'false'
    word = word.to_i if (word.is_a?(String) && word.float?)
    $state.deque = (left ? [word] + $state.deque : $state.deque + [word]).flatten
end

def trace(instruction = $state.previous)
    puts "#{instruction}\t=> #{$state.deque.inspect}"
end