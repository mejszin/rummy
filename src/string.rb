class String
    def left?
        self[0] == DIRECTION_INDICATOR
    end

    def right?
        self[-1] == DIRECTION_INDICATOR
    end

    def float?
        true if Float self rescue false
    end

    def label?
        self[-1] == LABEL_INDICATOR
    end
    
    def word?
        return self[0..-2] if self.label?
        return self[1..-1] if self.left?
        return self[0..-2] if self.right?
        return self
    end
end