class Solver
  class BinStrategy < NaiveStrategy
    def try_solve
      @bin_dict = []
      prepare_bin_dict
      #p @bin_dict
    end
  
    def prepare_bin_dict
      if @operators.include?(:tfold)
        node = naive_search(BV::Node.get(:tfold), @ops_candidate)
      else
        node = naive_search(BV::Node::Lambda.new(1), @ops_candidate)
      end
    end
  end
end
