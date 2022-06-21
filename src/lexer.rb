DIRECTION_INDICATOR = "!"
LABEL_INDICATOR = ":"
COMMENT_INDICATOR = "#"

def lex(lines)
    words = []
    labels = {}
    # Flatten all words into an array
    for line in lines do
        line_words = line.chomp.split(' ')
        words += line_words unless line_words.first == COMMENT_INDICATOR
    end
    words.flatten.each_with_index { |w, i| labels[w.word?] = i if w.label? }
    return words.flatten, labels
end

def initial_deque(argv)
    arr = []
    for term in argv do
        unless term[0, 2] == '--'
            arr << term
        end
    end
    return arr
end