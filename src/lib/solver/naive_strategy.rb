class Solver
  class NaiveStrategy < Strategy
    def initialize(size, operators, inputs, outputs)
      super
      # アサイン済みのoperator
      @assigned_ops = []

      # e[n]それぞれの重複を許す回数。nはopが保持するeの数
      # e[0]は不使用
      @e_dup_max = calc_e_dep_max

      # 候補opの初期化
      init_candidate(@operators)
    end

    def try_solve
      # TFoldは最初の候補に確定
      if @operators.include?(:tfold)
        node = naive_search(BV::Node.get(:tfold), @ops_candidate, [], @size, @inputs, @outputs)
      else
        node = naive_search(BV::Node::Lambda.new(1), @ops_candidate, [], @size, @inputs, @outputs)
      end
      if node
        return @bv.ast_to_program(node.to_a)
      else
        return false
      end
    end

    # 再帰的に呼び出し候補をすべて試すメソッド
    # 最終的に答えが見つかったnodeを返す
    def naive_search(node, ops_candidate, used_ops, size, inputs, outputs)
      ops = ops_candidate.dup
      #p "--------#{node}----------"

      # 割り当てられていないのにサイズがオーバー
      if !node.root.assigned? && node.root.size >= size
        return false
      end

      # すべて割り当てて済み && 未選択のオペレータがない
      #p assigned: node.root.assigned?, node: node.root.to_a.to_s, size: size
      if node.root.assigned? &&
          node.root.size == size &&
          used_all_op?(ops_candidate, used_ops)
        #p "------ assigned -------"
        return do_complete_node(node, inputs, outputs)
      end

      # 候補の組み合わせを作ってexp分はめていく
      candidate = ops_candidate + 
        node.assignable_exp_max.times.map{[0, 1, *node.selectable_ids]}.flatten
      #p candidate: candidate
      #p exp_max: node.assignable_exp_max
      candidate.permutation(node.assignable_exp_max).to_a.uniq.each do |comb|
        #p comb: comb, node: node.root.to_a
        comb.map {|c| node.push_exp(c) }.each do |exp|
          comb.each{|c| used_ops << c }
          if n = naive_search(exp, unselected_ops(ops, comb), used_ops, size, inputs, outputs)
            comb.each{|c| used_ops.pop }
            return n
          end
          comb.each{|c| used_ops.pop }
        end

        while node.pop_exp; end
      end

      return false
    end

    private
    def init_candidate(operators)
      candidate = operators.dup
      candidate.delete(:tfold)
      # expが少ないもの順の優先度
      candidate.sort!{|c| BV::Node.get(c).exp_size}
      @ops_candidate = candidate.dup
      # 重複可能なopを可能な数まで増やす
      candidate.each do |c|
        (@e_dup_max[BV::Node.get(c).exp_size]-1).times.map{ c }.to_a.each do |dup|
          # 重複分は優先度を下げる
          @ops_candidate << dup
        end
      end
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

    def used_all_op?(ops, used_ops)
      (ops - used_ops).empty?
    end

    # それぞれのoperatorのeに応じた重複可能数の計算
    def calc_e_dep_max
      e_dup_max = []

      # 全体のexpのサイズ
      all = @operators.map{|o| BV::Node.get(o).exp_size }.inject(&:+)
      # Lambdaの分1を足す
      all += 1 if not @operators.include?(:tfold)

      exp_maxs = @operators.reject{|o| o == :tfold }.map do |o|
        BV::Node.get(o).exp_size
      end.uniq.sort

      exp_maxs.each do |max|
        # それぞれ持ちうるeを足して全体のサイズから引くとeを入れる可能な数がでる
        room = @size - all

        # あといくついれられるか
        if room >= (max + 1)
          # (op 1) という形を入れたとすると
          room -= (max + 1)
          e_dup_max[max] = (room / max) + 2
        else
          e_dup_max[max] = 1
        end
      end
      return e_dup_max
    end

    def do_complete_node(node, inputs, outputs)
      # p node: node.root.to_a
      if correct?(node.root.to_a, inputs, outputs)
        return node.root
      else
        return false
      end
    end
  end
end
