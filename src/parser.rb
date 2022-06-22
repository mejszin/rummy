class Rummy
    def interpret
        ip = 0
        until ip >= @program.length
            @current, @previous = @program[ip], @current
            case @current.word?
            when 'add'
                push(pop(2).reduce(:+))
            when 'subtract'
                push(pop(2).reverse.reduce(:-))
            when 'mod'
                push(pop(2).reverse.reduce(:%))
            when 'equals'
                push(pop(2).reduce(:==))
            when 'gt'
                push(pop(2).reduce(:>))
            when 'lt'
                push(pop(2).reduce(:<))
            when 'ceil'
                push(pop().ceil)
            when 'floor'
                push(pop().floor)
            when 'and'
                push(pop(2).reduce(:&))
            when 'or'
                push(pop(2).reduce(:|))
            when 'xor'
                push(pop(2).reduce(:^))
            when 'not'
                push(!pop())
            when 'dup'
                push([pop()] * 2)
            when 'drop'
                pop()
            when 'swap'
                push(self.right? ? pop(2) : pop(2).reverse)
            when 'rotate'
                push(pop(), self.right?)
            when 'upcase'
                push(pop().upcase)
            when 'downcase'
                push(pop().downcase)
            when 'concat'
                push(self.right? ? pop(2).reverse.join : pop(2).join)
            when 'trace'
                trace()
            when 'clear'
                clear()
            when 'jmp'
                @jump_stack << ip
                ip = label(pop())
            when 'jmpif'
                @jump_stack << ip
                bool, label = pop(2)
                ip = label(label) if bool
            when 'input'
                a = STDIN.gets.chomp
                push(a)
            when 'alias'
                key, val = pop(2)
                # Key value is overwritten incase previously defined
                key = @program[ip - 2].word?
                @aliases[key] = val
            when 'return'
                ip = @jump_stack.last
                @jump_stack = @jump_stack[0..-2]
            when 'print'
                val = pop()
                print "#{val.to_s.unescape}\n" if @verbose_mode
            when 'include'
                include_program(pop(), ip)
            when 'run'
                param_count, verbose, path = pop(3)
                run_program(path, verbose, param_count).each { |val| push(val) }
            when 'exit'
                return
            else
                push(@current.word?) unless @current.label?
            end
            trace(@current) if @trace_mode
            ip += 1
        end
        return @deque
    end
end