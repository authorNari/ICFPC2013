require 'bv'
require 'api'
require 'timeout'

class Solver
  def solve(id, size, operators, strategy=:liberta)
    operators = operators.map(&:to_sym)
    inputs = 10.times.map{ rand(0xFFFFFFFFFFFFFF) }
    res = Api.eval(id: id, inputs: inputs)
    outputs = res['outputs'].map{|o| o.to_i(16) }

    case strategy
    when :liberta
      timeout(300) do
        while true
          @strategy = LibertaStrategy.new(size, operators, inputs, outputs)
          if answer = @strategy.try_solve
            res = Api.guess(id: id, program: answer)
            if res['status'] == 'win'
              return true
            else
              inputs += [res['values'][0].to_i(16)]
              outputs += [res['values'][1].to_i(16)]
            end
          else
            return false
          end
        end
      end
    when :naive
      timeout(300) do
        while true
          @strategy = NaiveStrategy.new(size, operators, inputs, outputs)
          if answer = @strategy.try_solve
            res = Api.guess(id: id, program: answer)
            if res['status'] == 'win'
              return true
            else
              inputs += [res['values'][0].to_i(16)]
              outputs += [res['values'][1].to_i(16)]
            end
          else
            return false
          end
        end
      end
    end
    return false
  end
end

require 'solver/strategy'
require 'solver/naive_strategy'
require 'solver/bin_strategy'
require 'solver/liberta_strategy'
