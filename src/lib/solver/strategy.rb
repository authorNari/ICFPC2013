class Solver
  class Strategy
    def initialize(size, operators, inputs, outputs)
      @size = size
      @operators = operators
      @inputs = inputs
      @outputs = outputs
      @bv = BV.new
    end

    def try_solve
      raise 'not implemented'
    end

    private
    def correct?(ast)
      res = @inputs.zip(@outputs).all? do |i, o|
        o == @bv.eval_program(ast, i)
      end
      return res
    end
  end
end
