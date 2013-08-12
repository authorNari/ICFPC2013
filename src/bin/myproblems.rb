base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))

require 'solver'

#max_size = eval(ARGV[0]).to_i
res = Api.myproblems
res.sort_by!{|json| json['size'] }

res.each do |json|
  if ((!(json['operators'].include?('tfold') || json['operators'].include?('fold') || json['operators'].include?('bonus'))) &&
      json['solved'].nil? &&
      json['size'] <= 20
  )
    begin
      p [json['id'], json['size'], json['operators']]
      puts Solver.new.solve(json['id'], json['size'], json['operators'])
      sleep 10
    rescue => ex
      puts ex
    end
  end
end
