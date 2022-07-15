class Rummy
    def DoGoto(ip)
        new_ip = label(pop())
        ip = new_ip unless new_ip == nil
    end

    def DoGotoIf(ip)
        label, bool = pop(2)
        if bool
            new_ip = label(label)
            ip = new_ip unless new_ip == nil
        end
        return ip
    end

    def DoJmp(ip)
        @jump_stack << [ip, @contextual_left]
        new_ip = label(pop())
        ip = new_ip unless new_ip == nil
        return ip
    end

    def DoJmpIf(ip)
        label, bool = pop(2)
        if bool
            @jump_stack << [ip, @contextual_left]
            new_ip = label(label)
            ip = new_ip unless new_ip == nil
        end
        return ip
    end
end