class Rummy
    OPENER_WORDS = [Dictionary::Proc, Dictionary::If, Dictionary::Unless, Dictionary::With, Dictionary::As]

    def block_opener(ip)
        return @program[up_to_opener(ip, OPENER_WORDS, [Dictionary::End])]
    end

    def up_to_opener(ip, openers, closers)
        layer = 1
        until (openers.include?(@program[ip].word?) && (layer == 0))
            ip -= 1
            layer -= 1 if openers.include?(@program[ip].word?)
            layer += 1 if closers.include?(@program[ip].word?)
        end
        return ip
    end

    def down_to_closer(ip, openers, closers)
        layer = 1
        until (closers.include?(@program[ip].word?) && (layer == 0))
            ip += 1
            layer += 1 if openers.include?(@program[ip].word?)
            layer -= 1 if closers.include?(@program[ip].word?)
        end
        return ip
    end

    def down_to_delimeter(ip, openers, delimeters, closers)
        layer = 1
        until ((delimeters.include?(@program[ip].word?) && (layer == 1)) || (closers.include?(@program[ip].word?) && (layer == 0)))
            ip += 1
            layer -= 1 if closers.include?(@program[ip].word?)
            layer += 1 if openers.include?(@program[ip].word?)
        end
        return ip
    end

    def do_Return(ip)
        new_ip, new_left = @jump_stack.last
    #   if ((@last_jump == new_ip) && (@last_deque == @deque))
    #       until (@jump_stack.last[0] != @last_jump)
    #           @jump_stack = @jump_stack[0..-2]
    #       end
    #       new_ip, new_left = @jump_stack.last
    #   end
        ip = new_ip unless new_ip == nil
        @contextual_left = new_left unless new_left == nil
        @jump_stack = @jump_stack[0..-2]
        @last_jump, @last_deque = new_ip, @deque
        @local_aliases = @local_aliases[0..-2] unless @local_aliases.empty?
        return ip
    end

    def do_ReturnIf(ip)
        bool = pop()
        if bool
            new_ip, new_left = @jump_stack.last
            ip = new_ip unless new_ip == nil
            @contextual_left = new_left unless new_left == nil
            @jump_stack = @jump_stack[0..-2]
        end
    end

    def do_Repeat(ip)
        return ip
    end

    def do_With(ip)
        return ip
    end

    def do_In(ip)
        opener_ip = ip
        until [Dictionary::Proc, Dictionary::With, Dictionary::As].include?(@program[opener_ip])
            opener_ip -= 1
        end
        # Get Proc args
        if @program[opener_ip] == Dictionary::Proc
            args = @program[(opener_ip + 1)..(ip - 2)]
            args = args.reverse if @program[ip].right?
        end
        # Get With/As args
        if [Dictionary::With, Dictionary::As].include?(@program[opener_ip])
            args = [pop(ip - opener_ip - 1)].flatten
        end
        @local_aliases << Hash[args.zip([pop(args.length)].flatten)]
        return ip
    end

    def do_End(ip)
        @local_aliases = @local_aliases[0..-2] if [Dictionary::With, Dictionary::As].include?(block_opener(ip).word?)
        return ip
    end

    def do_Next(ip)
        return up_to_opener(ip, [Dictionary::Repeat], [Dictionary::Until])
    end

    def do_Until(ip)
        bool = pop()
        ip = up_to_opener(ip, [Dictionary::Repeat], [Dictionary::Until]) unless bool
        return ip
    end

    def do_Proc(ip)
        ip += 1 until (@program[ip + 1].word? == Dictionary::In)
        @labels[@program[ip]] = ip
        return down_to_closer(ip, OPENER_WORDS, [Dictionary::End])
    end

    def do_If(ip)
        bool = pop()
        ip = down_to_delimeter(ip, [Dictionary::If, Dictionary::Unless], [Dictionary::Else], [Dictionary::End]) unless bool
        return ip
    end

    def do_Unless(ip)
        bool = pop()
        ip = down_to_delimeter(ip, [Dictionary::If, Dictionary::Unless], [Dictionary::Else], [Dictionary::End]) if bool
        return ip
    end

    def do_Else(ip)
        return down_to_closer(ip, [Dictionary::If, Dictionary::Unless], [Dictionary::End])
    end
end