require_relative './src/string.rb'
require_relative './src/lexer.rb'
require_relative './src/parser.rb'
require_relative './src/state.rb'

$state = State.new.tap do |s|
    s.path = ARGV[0]
    s.trace_mode = ARGV.include?('--trace')
    s.deque = []
    s.jump_stack = []
    s.program, s.labels = *lex(File.readlines(s.path))
end

initial_deque(ARGV[1..-1]).each { |term| push(term, false) }

interpret()