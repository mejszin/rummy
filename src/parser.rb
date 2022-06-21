def interpret
    ip = 0
    until ip >= $state.program.length
        $state.current, $state.previous = $state.program[ip], $state.current
        case $state.current.word?
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
            push($state.right? ? pop(2) : pop(2).reverse)
        when 'rotate'
            push(pop(), $state.right?)
        when 'upcase'
            push(pop().upcase)
        when 'downcase'
            push(pop().downcase)
        when 'concat'
            push($state.right? ? pop(2).reverse.join : pop(2).join)
        when 'trace'
            trace()
        when 'clear'
            $state.clear
        when 'jmp'
            $state.jump_stack << ip
            label = pop()
            ip = $state.label(label)
        when 'jmpif'
            $state.jump_stack << ip
            bool, label = pop(2)
            ip = $state.label(label) if bool
        when 'return'
            ip = $state.jump_stack.last
            $state.jump_stack = $state.jump_stack[0..-2]
        when 'print'
            print "#{pop().unescape}\n"
        when 'exit'
            return
        else
            push($state.current.word?) unless $state.current.label?
        end
        trace($state.current) if $state.trace_mode
        ip += 1
    end
end

