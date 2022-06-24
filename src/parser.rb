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
                a, b = pop(2)
                unless ((a == nil) || (b == nil))
                    push(self.right? ? [a, b] : [b, a])
                end
            when 'rotate'
                push(pop(), self.right?)
            when 'upcase'
                push(pop().upcase)
            when 'downcase'
                push(pop().downcase)
            when 'concat'
                a, b = pop(2)
                unless ((a == nil) || (b == nil))
                    push(self.right? ? [a, b].reverse.join : [a, b].join)
                end
            when 'chr'
                push(pop().chr)
            when 'ord'
                push(pop().ord)
            when 'trace', 'inspect'
                trace(ip)
            when 'length'
                push(@deque.length)
            when 'clear'
                clear()
            when 'jmp'
                @jump_stack << ip
                new_ip = label(pop())
                ip = new_ip unless new_ip == nil
            when 'jmpif'
                label, bool = pop(2)
                if bool
                    @jump_stack << ip
                    new_ip = label(label)
                    ip = new_ip unless new_ip == nil
                end
            when 'number?'
                push(pop().is_number?)
            when 'input'
                a = STDIN.gets.chomp
                push(a)
            when 'alias'
                key, val = pop(2)
                # Key value is overwritten incase previously defined
                key = @program[ip - 2].word?
                @aliases[key] = val
            when 'return'
                new_ip = @jump_stack.last
                unless new_ip == nil
                    ip = new_ip
                end
                @jump_stack = @jump_stack[0..-2]
            when 'returnif'
                bool = pop()
                if bool
                    new_ip = @jump_stack.last
                    ip = new_ip unless new_ip == nil
                    @jump_stack = @jump_stack[0..-2]
                end
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
                word = @current.word?
                push(word) unless @current.label?
            end
            trace(@current) if @trace_mode
            ip += 1
        end
        return @deque
    end
end