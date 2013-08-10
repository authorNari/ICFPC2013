class Solver
  class NaiveStrategy < Strategy
    def initialize(size, operators, inputs, outputs)
      super
      # アサイン済みのoperator
      @assigned_ops = []
      # e[n]それぞれの重複を許す回数。nはopが保持するeの数
      # e[0]は不使用
      # TODO: 重複可能数の計算
      @e_dup_max = [nil, 1, 1, 1]
      # 候補opの初期化
      init_candidate(@operators)
    end

    def try_solve
      # TFoldは最初の候補に確定
      if @operators.include?(:tfold)
        node = naive_search(BV::Node.get(:tfold), @ops_candidate)
      else
        node = naive_search(BV::Node::Lambda.new(1), @ops_candidate)
      end
      if node
        return node.to_a
      else
        return false
      end
    end

    # 再帰的に呼び出し候補をすべて試すメソッド
    # 最終的に答えが見つかったnodeを返す
    def naive_search(node, ops_candidate)
      ops = ops_candidate.dup
      #p "--------#{node}----------"

      # すべて割り当てて済み && 未選択のオペレータがない
      #p assigned: node.root.assigned?
      if node.root.assigned? && ops_candidate.empty?
        #p "------ assigned -------"
        # 正しい式か？
        if correct?(node.root.to_a)
          return node.root
        else
          return false
        end
      end

      # 候補の組み合わせを作ってexp分はめていく
      candidate = ops_candidate + [0, 1, *node.selectable_ids]
      #p candidate: candidate
      #p exp_max: node.assignable_exp_max
      candidate.permutation(node.assignable_exp_max) do |comb|
        #p comb: comb
        comb.map {|c| node.push_exp(c) }.each do |exp|
          if n = naive_search(exp, unselected_ops(ops, comb))
            return n
          end
        end

        if node.has_lambda?
          node.lambda = BV::Lambda.new
          if n = naive_search(node.lambda, unselected_ops(ops, comb))
            return n
          end

          node.lambda = nil
        end

        while node.pop_exp; end
      end

      return false
    end

    private
    def init_candidate(operators)
      candidate = operators.dup
      candidate.delete(:tfold)
      # 重複可能なopを可能な数まで増やす
      @ops_candidate = candidate.map do |c|
        @e_dup_max[BV::Node.get(c).exp_size].times.map{ c }.to_a
      end.flatten
    end

    # 重複に気を使って、未選択のop配列を返す。
    def unselected_ops(ops, selected)
      ops = ops.dup
      #p bf_ops: ops
      selected.each{|s|
        if i = ops.index(s)
          ops[i] = nil
        end
      }
      #p af_ops: ops
      return ops.compact
    end
  end
end
