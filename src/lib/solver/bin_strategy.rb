class Solver
  class BinStrategy < Strategy
    def try_solve
      @bin_dict = []
      prepare_bin_dict
      #p @bin_dict
    end
  
    def prepare_bin_dict
      if @operators.include?(:tfold)
        node = naive_search(BV::Node.get(:tfold), [])
      else
        node = naive_search(BV::Node::Lambda.new(1), [])
      end
    end
  
    # もう少しシンプルにしてみた
    def naive_search(node, used_operators)
      #p "---- #{node.to_s} ----"
      # まだ使ってないオペレータで割り当てられていないexpの合計
      unused_op_exp =
        (@operators - used_operators).map{|op| BV::Node.get(op).exp_size }.inject(&:+).to_i
  
      # このままだとオペレータを使い切れない
      #p root: node.root.to_a, root_size: node.root.size, unused_op_exp: unused_op_exp, size: @size
      if (node.root.size + unused_op_exp) > @size
        return false
      end

      # すべて割り当て済み
      root = node.root
      if root.assigned?
        # だがサイズがおかしい
        return false if root.size != @size
        # opを使い切れていない
        return false if unused_op_exp > 0
        # @bin_dict << root.to_a
        return
      end

      if node.root.size == @size
        return false
      end
  
      # 候補作り出し
      candidates = @operators +
        node.assignable_exp_max.times.map{[0, 1, *node.selectable_ids]}.flatten
  
      # 候補を割り当て可能なexp分の順列にする
      candidates.permutation(node.assignable_exp_max).each do |perm|
        # 幅優先で割りあて
        perm.each do |op|
          exp = node.push_exp(op)
          used_operators << op
        end

        node.exps.each do |exp|
          break unless naive_search(exp, used_operators)
        end

        while node.pop_exp
          used_operators.pop
        end
      end
    end
  end
end
