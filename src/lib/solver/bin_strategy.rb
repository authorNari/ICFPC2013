class Solver
  class BinStrategy < NaiveStrategy
    def try_solve
      @bin_dict = []
      prepare_bin_dict
    end
  
    def prepare_bin_dict
      @try_inputs = [0x0, 0xFFFFFFFFFFFFFFFF]
      @try_inputs += 8.times.map{ rand(0xFFFFFFFFFFFFFFFF) }
      # [(input, output), ..]がキー。重複は削除
      @bin_dict = {}

      if @operators.include?(:tfold)
        node = naive_search(BV::Node.get(:tfold), @ops_candidate)
      else
        node = naive_search(BV::Node::Lambda.new(1), @ops_candidate)
      end
      p @bin_dict.size
    end

    def do_complete_node(node)
      ast = node.root.to_a
      key = @try_inputs.map do |i|
        [i, @bv.eval_program(ast, i)]
      end
      @bin_dict[key] = ast
      return false
    end
  end
end
