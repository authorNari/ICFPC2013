class BV
  class Node
    def initialize
      @exps = []
      @ids = []
      @assignable_exp_max = 0
      @assignable_id_max = 0
      @has_lambda = false
      @parent = nil
    end
    attr_accessor :parent
    attr_reader :assignable_exp_max, :assignable_id_max

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
      else
        raise "unsupported opperator: #{op}"
      end
    end

    def push_exp(e)
      case e
      when 1, 0
        e = Num.new(e)
      when Symbol
        e = Variable.new(e)
      end
      if @exps.size == assignable_exp_max
        return nil
      end
      @exps << e
      e.parent = self
      return e
    end

    def pop_exp
      e = @exps.pop
      e.parent = nil
      return e
    end

    def push_id(id)
      if @ids.size == assignable_id_max
        return nil
      end
      @ids << id
    end

    def pop_id
      @ids.pop
    end

    def has_lambda?
      @has_lambda
    end

    def to_a
      raise "not implemented"
    end

    def selectable_ids
      if parent.nil?
        []
      else
        @ids + parent.selectable_ids
      end
    end

    def to_s
      return "#<BV::Node: #{to_a.to_s}>"
    end

    class If0 < Node
      def initialize
        super
        @assignable_exp_max = 3
      end

      def to_a
        [:if0] + @exps[0].to_a + @exps[1].to_a + @exps[2].to_a
      end
    end

    class Fold < Node
      def initialize
        super
        @assignable_exp_max = 2
        @has_lambda = true
        @lambda = nil
      end

      def lambda=(node)
        @lambda = node
        node.parent = self
      end

      def to_a
        [:fold] + @exps[0].to_a + @exps[1].to_a << @lambda.to_a
      end
    end

    class TFold < Node
      def initialize
        super
        @assignable_exp_max = 1
        @has_lambda = true
      end

      def to_a
        [:lambda, [:x], [:fold, :x, 0, [:lambda, [:x, :y], *@exps[0].to_a]]]
      end
    end

    class Lambda < Node
      def initialize
        super
        @assignable_exp_max = 1
        @assignable_id_max = 2
      end

      def to_a
        [:lambda] + [@ids] + @exps[0].to_a
      end
    end

    class OP1 < Node
      def initialize(op)
        super()
        @assignable_exp_max = 1
        @op = op
      end

      def to_a
        [@op] + @exps[0].to_a
      end
    end

    class OP2 < Node
      def initialize(op)
        super()
        @assignable_exp_max = 2
        @op = op
      end

      def to_a
        [@op] + @exps[0].to_a + @exps[1].to_a
      end
    end

    class Num < Node
      def initialize(num)
        super()
        @num = num
      end

      def to_a
        [@num]
      end
    end
  end

  class Variable < Node
    def initialize(label)
      super()
      @label = label
    end

    def to_a
      [@label]
    end
  end
end