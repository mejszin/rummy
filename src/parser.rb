BLOCK_WORDS = ['proc', 'if', 'unless']

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
            when 'equals', '='
                push(pop(2).reduce(:==))
            when 'gt', '>'
                push(pop(2).reduce(:>))
            when 'lt', '<'
                push(pop(2).reduce(:<))
            when 'and', '&'
                push(pop(2).reduce(:&))
            when 'or', '|'
                push(pop(2).reduce(:|))
            when 'xor', '^'
                push(pop(2).reduce(:^))
            when 'not'
                push(!pop())
            when 'dup'
                push([pop()] * 2)
            when 'drop'
                pop()
            when 'swap'
                pop(2).each { |v| push(v) }
            when 'rotate'
                push(pop(), self.right?)
            when 'chars'
                pop().chars.each { |c| push(c) }
            when 'concat'
                a, b = pop(2)
                push(a.to_s + b.to_s)
            when 'chr'
                push(pop().to_i.chr)
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
                @jump_stack << [ip, @contextual_left]
                new_ip = label(pop())
                ip = new_ip unless new_ip == nil
            when 'jmpif'
                label, bool = pop(2)
                if bool
                    @jump_stack << [ip, @contextual_left]
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
                new_ip, new_left = @jump_stack.last
                if ((@last_jump == new_ip) && (@last_deque == @deque))
                    @jump_stack = @jump_stack[0..-2] until (@jump_stack.last[0] != @last_jump)
                    new_ip, new_left = @jump_stack.last
                end
                ip = new_ip unless new_ip == nil
                @contextual_left = new_left unless new_left == nil
                @jump_stack = @jump_stack[0..-2]
                @last_jump, @last_deque = new_ip, @deque
            when 'returnif'
                bool = pop()
                if bool
                    new_ip, new_left = @jump_stack.last
                    ip = new_ip unless new_ip == nil
                    @contextual_left = new_left unless new_left == nil
                    @jump_stack = @jump_stack[0..-2]
                end
            when 'repeat'
            when 'until'
                bool = pop()
                unless bool
                    layer = 1
                    until ((@program[ip].word? == 'repeat') && (layer == 0))
                        ip -= 1
                        layer -= 1 if (@program[ip].word? == 'repeat')
                        layer += 1 if (@program[ip].word? == 'until')
                    end
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
                #new_ip = @jump_stack.last
                #unless new_ip == nil
                #    @contextual_left = false
                #    ip = new_ip 
                #    @jump_stack = @jump_stack[0..-2]
                #end
            when 'if'
                bool = pop()
                unless bool
                    layer = 1
                    until (((@program[ip] == 'else') && (layer == 1)) || 
                           ((@program[ip] == 'end' ) && (layer == 0)))
                        ip += 1
                        layer -= 1 if ['end'].include?(@program[ip].word?)
                        layer += 1 if ['if', 'unless'].include?(@program[ip].word?)
                    end
                end
            when 'unless'
                bool = pop()
                if bool
                    layer = 1
                    until (((@program[ip] == 'else') && (layer == 1)) || 
                           ((@program[ip] == 'end' ) && (layer == 0)))
                        ip += 1
                        layer -= 1 if ['end'].include?(@program[ip].word?)
                        layer += 1 if ['if', 'unless'].include?(@program[ip].word?)
                    end
                end
            when 'else'
                layer = 1
                until ((@program[ip] == 'end') && (layer == 0))
                    ip += 1 
                    layer -= 1 if ['end'].include?(@program[ip].word?)
                    layer += 1 if ['if', 'unless'].include?(@program[ip].word?)
                end
            when 'exit'
                return
            else
                if @labels.key?(@current.word?)
                    @jump_stack << [ip, @contextual_left]
                    @contextual_left = @contextual_left ? !@current.left? : @current.left?
                    new_ip = label(@current.word?)
                    ip = new_ip unless new_ip == nil
                else
                    unless @current.label?
                        word = @current.word?
                        push(word)
                    end
                end
            end
            trace(ip, @current) if @trace_mode
            ip += 1
            #puts "Next: (#{ip}) #{@program[ip]}"
        end
        return @deque
    end
end