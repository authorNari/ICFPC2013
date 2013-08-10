base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))

require 'solver'

p ARGV
p Solver::NaiveStrategy.new(
  ARGV[0].to_i,
  eval(ARGV[1]).map(&:to_sym),
  eval(ARGV[2]),
  eval(ARGV[3])
).try_solve
