class Rummy
    def interpret
        ip = 0
        until ip >= @program.length
            @current, @previous = @program[ip], @current
            case @current.word?
            when Dictionary::Add
                vars = pop(2)
                push(vars.reduce(:+))
            when Dictionary::Subtract
                push(pop(2).reverse.reduce(:-))
            when Dictionary::Multiply
                push(pop(2).reverse.reduce(:*))
            when Dictionary::Divide
                push(pop(2).reverse.map { |n| n.to_f }.reduce(:/))
            when Dictionary::Modulo
                push(pop(2).reverse.reduce(:%))
            when Dictionary::Equals
                push(pop(2).reduce(:==))
            when Dictionary::GreaterThan
                push(pop(2).reduce(:>))
            when Dictionary::LessThan
                push(pop(2).reduce(:<))
            when Dictionary::And
                push(pop(2).reduce(:&))
            when Dictionary::Or
                push(pop(2).reduce(:|))
            when Dictionary::Xor
                push(pop(2).reduce(:^))
            when Dictionary::Not
                push(!pop())
            when Dictionary::Dup
                push([pop()] * 2)
            when Dictionary::Drop
                pop()
            when Dictionary::Swap
                pop(2).each { |v| push(v) }
            when Dictionary::Rotate
                push(pop(), self.right?)
            when Dictionary::Chars
                pop().prettify.to_s.chars.each { |c| push(c) }
            when Dictionary::Concat
                a, b = pop(2)
                push(a.to_s + b.to_s)
            when Dictionary::Chr
                push(pop().to_i.chr)
            when Dictionary::Ord
                push(pop().ord)
            when Dictionary::Inspect
                trace(ip)
            when Dictionary::Size
                push(@deque.length)
            when Dictionary::Goto
                ip = do_Goto(ip)
            when Dictionary::GotoIf
                ip = do_GotoIf(ip)
            when Dictionary::Jmp
                ip = do_Jmp(ip)
            when Dictionary::JmpIf
                ip = do_JmpIf(ip)
            when Dictionary::IsNumber
                push(pop().is_number?)
            when Dictionary::Input
                push(STDIN.gets.chomp)
            when Dictionary::Alias
                key, val = pop(2)
                @aliases[key] = val
            when Dictionary::Return
                ip = do_Return(ip)
            when Dictionary::ReturnIf
                ip = do_ReturnIf(ip)
            when Dictionary::Next
                ip = do_Next(ip)
            when Dictionary::Repeat
                ip = do_Repeat(ip)
            when Dictionary::Until
                ip = do_Until(ip)
            when Dictionary::Print
                val = pop()
                val = val.to_f.prettify if val.is_number?
                print "#{val.to_s.unescape}\n" if @verbose_mode
            when Dictionary::Include
                include_program(pop(), ip)
            when Dictionary::Run
                param_count, verbose, path = pop(3)
                run_program(path, verbose, param_count).each { |val| push(val) }
            when Dictionary::Proc
                ip = do_Proc(ip)
            when Dictionary::With
                ip = do_With(ip)
            when Dictionary::As
                ip = do_With(ip)
            when Dictionary::In
                ip = do_In(ip)
            when Dictionary::End
                ip = do_End(ip)
            when Dictionary::If
                ip = do_If(ip)
            when Dictionary::Unless
                ip = do_Unless(ip)
            when Dictionary::Else
                ip = do_Else(ip)
            when Dictionary::Exit
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