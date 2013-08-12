# クラス名は歴史的理由によるもの
# （松江の地中海料理屋LIBERTAでスパゲティを食べながらナプキンに書きなぐっ
#   たコードと言い伝えられている）
class Solver
  class LibertaStrategy < NaiveStrategy
    def try_solve
      root = node = BV::Node::Lambda.new(1)
      arg = [@ops_candidate, @inputs, @outputs]
      res = true
      while res
        if res = solve_if0(node, *arg)
          #p if0_node: node.to_a
          node = res[0]
          arg = res[1..-1]
          #p node: node.to_a
        end
        #p if0: node.to_a, root: root.to_a, if0_id: node.object_id
        if res = solve_op(node, *arg)
          node = res[0]
          arg = res[1..-1]
          #p node: node.to_a
        end
        #p op: node.to_a, root: root.to_a, op_id: node.object_id
      end
      
      #p finish: root.to_a
      if root.assigned? && root.size == @size
        @bv.ast_to_program(root.to_a)
      else
        return false
      end
    end

    def solve_if0(parent, candidate, inputs, outputs)
      #p solve_if0: [candidate, inputs, outputs]
      if candidate.detect{|op| op == :if0}
        res = naive_search(BV::Node::Lambda.new(1), [:if0], [], 5, inputs, outputs)
        if res
          if0 = res.exps[0]
          if0.parent = nil
          parent.assign_exp(if0)
          if parent.root.size == @size
            return false
          end
          cond = if0.exps[0]
          if0.exps[0] = nil
          case cond
          when BV::Node::Num
            outputs = inputs.map{ cond.num }
          when BV::Node::Variable
            outputs = inputs.map{|i| i }
          end
          candidate = unselected_ops(candidate, [:if0])
          return [if0, candidate, inputs, outputs]
        end
        return false
      else
        return false
      end
    end

    def solve_op(parent, candidate, inputs, outputs)
      #p solve_op: [candidate, inputs, outputs]
      if ops = candidate.select{|op| BV::OP1.include?(op) || BV::OP2.include?(op)}
        res = nil
        # あまりにも重複が多い場合は組み合わせが無理なので一意にする
        ops.uniq! if ops.size > 20
        # 4程度の組み合わせで限界
        1.step(4) do |perm_num|
          perm = ops.permutation(perm_num).to_a.map(&:compact).uniq
          puts "!---- answer -----!" if perm == [:shr1, :or, :plus]
          res = perm.find do |perm|
            #p perm
            size = perm.map{|c| BV::Node.get(c).exp_size }.inject(&:+) + 2
            r = naive_search(BV::Node::Lambda.new(1), perm, [], size, inputs, outputs)
            break r if r
          end
          break if res
        end
        if res
          op = root_op = res.exps[0]
          root_op.parent = nil
          parent.assign_exp(root_op)
          # p root_op_parent: root_op.parent.to_a
          # p parent_id: parent.object_id, op_parent_id: root_op.parent.object_id
          #p [parent.to_a, root_op.to_a, root_op.root.to_a, parent.root.size, @size]
          if parent.root.size == @size
            return false
          end
          while !((op.exps[0]).is_a?(BV::Node::Num) ||
              (op.exps[0]).is_a?(BV::Node::Variable))
            op = op.exps[0]
          end
          oparg1 = op.exps[0]
          case oparg1
          when BV::Node::Num
            outputs = inputs.map{ oparg1.num }
          when BV::Node::Variable
            outputs = inputs.map{|i| i }
          end
          op.exps[0] = nil
          candidate = unselected_ops(candidate, root_op.used_ops)
          return [root_op, candidate, inputs, outputs]
        end
      end
      return false
    end
  end
end
