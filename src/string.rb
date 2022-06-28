class String
    def left?
        self[0] == DIRECTION_INDICATOR
    end

    def right?
        self[0] != DIRECTION_INDICATOR
    end

    def label?
        self[-1] == LABEL_INDICATOR
    end

    def has_indicator?
        return (
            (self[0] == DIRECTION_INDICATOR) ||
            (self[-1] == DIRECTION_INDICATOR) ||
            (self[-1] == LABEL_INDICATOR)
        )
    end

    def float?
        true if Float self rescue false
    end

    def word?
        return self unless self.has_indicator?
        return self[0..-2] if self.label?
        return self[1..-1] if self.left?
        return self[0..-2] if self.right?
        return self
    end

    def unescape
        "\"#{self}\"".undump
    end

    def colorize(color)
        code = case color
        when :black   ; 30
        when :red     ; 31
        when :green   ; 32
        when :yellow  ; 33
        when :blue    ; 34
        when :magenta ; 35
        when :cyan    ; 36
        when :white   ; 37
        else          ; 37
        end
        "\e[#{code}m#{self}\e[0m"
    end
end

class Object
    def is_number?
        return false if !!self == self
        to_f.to_s == to_s || to_i.to_s == to_s
    end
end

class Float
    def prettify
        return (to_i == self) ? to_i : self
    end
end

class Integer
    def prettify
        return self
    end
end