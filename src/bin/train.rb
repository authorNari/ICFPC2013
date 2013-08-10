base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))

require 'solver'

begin
  res = Api.train
  sleep 5
end while res['size'] > 12

puts Solver.new.solve(res['id'], res['size'], res['operators'])
