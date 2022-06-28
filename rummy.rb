require_relative './src/string.rb'
require_relative './src/main.rb'
require_relative './src/lexer.rb'
require_relative './src/parser.rb'

if ((ARGV.length == 0) || (!File.exist?(ARGV[0])))
    puts "rummy_error: No valid file path given".colorize(:red)
    exit
end

begin_time = Time.now

rummy = Rummy.new(ARGV[0], :initial_deque => argv_deque(ARGV[1..-1]))
rummy.trace_mode = ARGV.include?('--trace')
result = rummy.interpret

end_time = Time.now

if rummy.trace_mode
    puts "rummy_info: Completed!".colorize(:green)
    puts "rummy_info: Time elapsed #{end_time - begin_time}s".colorize(:cyan)
    puts "rummy_info: Final state = #{result.inspect}".colorize(:cyan)
end