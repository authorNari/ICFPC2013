base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))

require 'solver'

max_size = eval(ARGV[0]).to_i
res = Api.myproblems

res.each do |json|
  if (max_size >= json['size'] ||
      (max_size+3 >= json['size'] && json['operators'].include?('tfold'))) &&
      json['solved'].nil?
    p [json['id'], json['size'], json['operators']]
    puts Solver.new.solve(json['id'], json['size'], json['operators'])
    sleep 10
  end
end
