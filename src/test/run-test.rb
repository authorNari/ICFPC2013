base_dir = File.expand_path(__dir__)
top_dir = File.expand_path(File.join(base_dir, ".."))
$LOAD_PATH.unshift(File.join(top_dir, "lib"))
$LOAD_PATH.unshift(File.join(top_dir, "test"))

require "bundler"
Bundler.require(:default, :test)
require "test/unit"

require "solver"

test_file = "./test/test_*.rb"
Dir.glob(test_file) do |file|
  require file
end
