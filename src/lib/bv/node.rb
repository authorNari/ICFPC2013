class BV
  class Node
    def initialize
      @exps = []
      @ids = []
      # 割り当て可能なexpの上限
      @assignable_exp_max = 0
      # 保持するexp数
      @exp_size = 0
      @has_lambda = false
      @parent = nil
    end
    attr_accessor :parent
    attr_reader :assignable_exp_max, :exp_size

    def self.get(op)
      case op
      when :if0
        If0.new
      when :lambda
        Lambda.new
      when :fold
        Fold.new
      when :tfold
        TFold.new
      when *BV::OP1
        OP1.new(op)
      when *BV::OP2
        OP2.new(op)
      when 1, 0
        Num.new(op)
      when Symbol
        Variable.new(op)
      else
        raise "unsupported opperator: #{op}"
      end
    end

    def push_exp(v)
      if @exps.size == assignable_exp_max
        return nil
      end
      e = self.class.get(v)
      @exps << e
      e.parent = self
      return e
    end

    def pop_exp
      e = @exps.pop
      e.parent = nil if not e.nil?
      return e
    end

    def has_lambda?
      @has_lambda
    end

    def to_a
      raise "not implemented"
    end

    def selectable_ids
      if parent.nil?
        @ids
      else
        @ids + parent.selectable_ids
      end
    end

    def to_s
      return "#<BV::Node: #{to_a.to_s}>"
    end

    # 子Nodeがアサイン済みであるか
    def assigned?
      res = (@exps.size == @assignable_exp_max)
      res &&= @exps.all?{|e| e.assigned? }
      res &&= (!@lambda.nil? && @lambda.assigned?) if has_lambda?
      return res
    end

    # 一番上のnode取得
    def root
      if parent.nil?
        self
      else
        t = parent
        while true
          break if t.parent.nil?
          t = t.parent
        end
        t
      end
    end

    class If0 < Node
      def initialize
        super
        @exp_size = @assignable_exp_max = 3
      end

      def to_a
        [:if0] << @exps[0].to_a << @exps[1].to_a << @exps[2].to_a
      end
    end

    class Fold < Node
      def initialize
        super
        @assignable_exp_max = 2
        @exp_size = 4
        @has_lambda = true
        @lambda = nil
      end

      def lambda=(node)
        @lambda = node
        node.parent = self
      end

      def to_a
        [:fold] << @exps[0].to_a << @exps[1].to_a << @lambda.to_a
      end
    end

    class TFold < Node
      def initialize
        super
        @assignable_exp_max = 1
        @exp_size = 5
        @has_lambda = false
        @ids = [:a, :b]
      end

      def to_a
        [:lambda, [:a], [:fold, :a, 0, [:lambda, [:a, :b], @exps[0].to_a]]]
      end
    end

    class Lambda < Node
      # 引数の数を指定。デフォルトは2。
      def initialize(arg_num=2)
        super()
        @exp_size = @assignable_exp_max = 1
        @ids = []
        @arg_num = arg_num
        if parent
          arg_num.times { @ids << parent.selectable_ids.last.to_s.succ.to_sym }
        else
          @ids = (arg_num == 1 ? [:a] : [:a, :b])
        end
      end

      def to_a
        [:lambda] << @ids << @exps[0].to_a
      end
    end

    class OP1 < Node
      def initialize(op)
        super()
        @exp_size = @assignable_exp_max = 1
        @op = op
      end

      def to_a
        [@op] << @exps[0].to_a
      end
    end

    class OP2 < Node
      def initialize(op)
        super()
        @exp_size = @assignable_exp_max = 2
        @op = op
      end

      def to_a
        [@op] << @exps[0].to_a << @exps[1].to_a
      end
    end

    class Num < Node
      def initialize(num)
        super()
        @num = num
      end

      def to_a
        @num
      end
    end
  end

  class Variable < Node
    def initialize(label)
      super()
      @label = label
    end

    def to_a
      @label
    end
  end
end
