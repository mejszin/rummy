BLOCK_WORDS = ['proc', 'if']

class Rummy
    def interpret
        ip = 0
        until ip >= @program.length
            @current, @previous = @program[ip], @current
            case @current.word?
            when 'add', '+'
                push(pop(2).reduce(:+))
            when 'subtract', '-'
                push(pop(2).reverse.reduce(:-))
            when 'multiply', '*'
                push(pop(2).reverse.reduce(:*))
            when 'divide', '/'
                push(pop(2).reverse.reduce(:/))
            when 'mod', '%'
                push(pop(2).reverse.reduce(:%))
            when 'equals'
                push(pop(2).reduce(:==))
            when 'gt'
                push(pop(2).reduce(:>))
            when 'lt'
                push(pop(2).reduce(:<))
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
            when 'chars'
                pop().chars.each { |c| push(c) }
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
            when 'size'
                push(@deque.length)
            when 'clear'
                clear()
            when 'goto'
                new_ip = label(pop())
                ip = new_ip unless new_ip == nil
            when 'gotoif'
                label, bool = pop(2)
                if bool
                    new_ip = label(label)
                    ip = new_ip unless new_ip == nil
                end
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
                # key = @program[ip - 2].word?
                @aliases[key] = val
            when 'return'
                new_ip = @jump_stack.last
                ip = new_ip unless new_ip == nil
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
                val = val.to_f.prettify if val.is_number?
                print "#{val.to_s.unescape}\n" if @verbose_mode
            when 'include'
                include_program(pop(), ip)
            when 'run'
                param_count, verbose, path = pop(3)
                run_program(path, verbose, param_count).each { |val| push(val) }
            when 'proc'
                @labels[pop()] = ip
                layer = 1
                until ((@program[ip] == 'end') && (layer == 0))
                    ip += 1
                    layer -= 1 if (@program[ip].word? == 'end')
                    layer += 1 if BLOCK_WORDS.include?(@program[ip].word?)
                end
            when 'end'
                @contextual_left = false
                new_ip = @jump_stack.last
                ip = new_ip unless new_ip == nil
                @jump_stack = @jump_stack[0..-2]
            when 'if'
                bool = pop()
                unless bool
                    ip += 1 until (['end', 'else'].include?(@program[ip]))
                    # @jump_stack = @jump_stack[0..-2] if @program[ip] == 'end'
                end
            when 'unless'
                bool = pop()
                if bool
                    ip += 1 until (['end', 'else'].include?(@program[ip]))
                    # @jump_stack = @jump_stack[0..-2] if @program[ip] == 'end'
                end
            when 'else'
                ip += 1 until @program[ip] == 'end'
            when 'exit'
                return
            else
                if @labels.key?(@current.word?)
                    @contextual_left = true if ((@current.left?) || (@contextual_left && @current.right?))
                    @jump_stack << ip
                    new_ip = label(@current.word?)
                    ip = new_ip unless new_ip == nil
                else
                    unless @current.label?
                        word = @current.word?
                        push(word)
                    end
                end
            end
            trace(@current) if @trace_mode
            ip += 1
        end
        return @deque
    end
end