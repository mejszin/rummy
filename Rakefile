KEYWORDS = {
    :deque     => { :color => '#93d6a9', :words => ['dup', 'drop', 'swap', 'rotate', 'length', 'clear'] },
    :math      => { :color => '#cca3b3', :words => ['add', '+', 'subtract', '-', 'multiply', '*', 'divide', '/', 'mod', '%', 'equals', 'gt', 'lt']},
    :check     => { :color => '#c0e0b0', :words => ['number?'] },
    :string    => { :color => '#80c0d9', :words => ['upcase' 'downcase', 'concat', 'chr', 'ord'] },
    :boolean   => { :color => '#8cd0d3', :words => ['true', 'false'] },
    :operator  => { :color => '#b3d38c', :words => ['and', 'or', 'xor', 'not'] },
    :pointer   => { :color => '#efaf7f', :words => ['goto', 'gotoif', 'jmp', 'jmpif', 'return', 'returnif', 'proc', 'end', 'if', 'unless', 'else', 'exit'] },
    :input     => { :color => '#f0dfaf', :words => ['input', 'alias', 'run', 'include'] },
    :output    => { :color => '#efaf7f', :words => ['trace', 'inspect', 'print'] },
    :direction => { :color => '#606060', :regex => '!' },
    :comment   => { :color => '#606060', :regex => '#(.*)' },
    :numbers   => { :color => '#8cd0d3', :regex => '\d' },
}

class String
    def without_symbol
        return self[1..-1] if self[0] == '!'
        return self[0..-2]  if self[-1] == '!'
        return self[0..-2]  if self[-1] == ':'
        return self
    end
end

task :test do
    code = "This !is 1st my! #string test"
    puts code.scan(/#{KEYWORDS[:direction][:regex]}/).inspect
    puts code.scan(/#{KEYWORDS[:comment][:regex]}/).inspect
    puts code.scan(/#{KEYWORDS[:numbers][:regex]}/).inspect
end

task :html do
    code = File.readlines(ENV['path'])
    code.map! do |line|
        # Word match
        line = line.split(' ').map! do |word|
            new_word = word
            for key, value in KEYWORDS do
                if (value.key?(:words) && value[:words].include?(word.without_symbol))
                    new_word = "<i class=\"#{key}\">#{word}</i>"
                end
            end
            new_word
        end.join(" ")
        # Direction match
        line.gsub!('!', "<i class=\"direction\">!</i>")
        # Comment match
        line.scan(/#{KEYWORDS[:comment][:regex]}/).each do |match|
            line.gsub!('#' + match[0], "<i class=\"comment\">#{'#' + match[0]}</i>")
        end
        line
    end
    puts code
end

task :vim_syntax do
    puts [
        "\" Deque (lucius=#93d6a9)",
        "syntax keyword Type #{KEYWORDS[:deque][:words].join(' ')}",
        "\" Mathematical (lucius=#cca3b3)",
        "syntax keyword Special #{KEYWORDS[:math][:words].join(' ')}",
        "\" Check (lucius=#c0e0b0)",
        "syntax keyword Directory #{KEYWORDS[:check][:words].join(' ')}",
        "\" String (lucius=#80c0d9)",
        "syntax keyword String #{KEYWORDS[:string][:words].join(' ')}",
        "\" Boolean operators (lucius=#b3d38c)",
        "syntax keyword Operator #{KEYWORDS[:operator][:words].join(' ')}",
        "\" Pointer (lucius=#efaf7f)",
        "syntax keyword Function #{KEYWORDS[:pointer][:words].join(' ')}",
        "\" Include / Input (lucius=#f0dfaf)",
        "syntax keyword Include #{KEYWORDS[:input][:words].join(' ')}",
        "\" Output (lucius=#efaf7f)",
        "syntax keyword Function #{KEYWORDS[:output][:words].join(' ')}",
        "\" Boolean (lucius=#8cd0d3)",
        "syntax keyword Boolean #{KEYWORDS[:boolean][:words].join(' ')}",
        "\" Direction (lucius=#606060)",
        "syntax match Comment \"\\v#{KEYWORDS[:direction][:regex]}\"",
        "\" Comment (lucius=#606060)",
        "syntax match Comment \"\\v#{KEYWORDS[:comment][:regex]}\"",
        "\" Numbers (lucius=#8cd0d3)",
        "syntax match Number \"\\v#{KEYWORDS[:numbers][:regex]}\"",
        "let b:current_syntax = \"rummy\"",
    ]
end