require_relative './src/string.rb'
require_relative './src/main.rb'
require_relative './src/dictionary.rb'
require_relative './src/goto.rb'
require_relative './src/block.rb'
require_relative './src/lexer.rb'
require_relative './src/parser.rb'


def print_error(message)
    puts "rummy_error: #{message.colorize(:italics)}".colorize(:red)
end

def print_info(message, color = :cyan)
    puts "rummy_info: #{message.colorize(:italics)}".colorize(color)
end

if ((ARGV.length == 0) || (!File.exist?(ARGV[0])))
    print_error("No valid file path given")
    exit
end

begin_time = Time.now

rummy = Rummy.new(ARGV[0], :initial_deque => argv_deque(ARGV[1..-1]))
rummy.trace_mode = ARGV.include?('--trace')
result = rummy.interpret

end_time = Time.now

if rummy.trace_mode
    print_info("Completed!", :green)
    print_info("Time elapsed #{end_time - begin_time}s")
    print_info("Final state = #{result.inspect}")
end