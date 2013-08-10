base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))

require 'solver'

operators = (eval(ARGV[1].to_s) || [])
res = Api.train(size: ARGV[0], operators: operators)

puts res['challenge']
puts Solver.new.solve(res['id'], res['size'], res['operators'])
