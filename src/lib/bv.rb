class BV
  PKEY = [:lambda]
  EKEY = [:if0, :fold]
  OP1 = [:not, :shl1, :shr1, :shr4, :shr16]
  OP2 = [:and, :or, :xor, :plus]

  def initialize
    @var_tables = []
  end

  def parse(str)
    str = /^\((.+)\)$/.match(str)[1]
    cur = []
    stack = []
    str.scan(/\(|\)|[\w\d]+/) do |token|
      case token
      when "0", "1"
        cur << token.to_i
      when "("
        stack << cur
        n = []
        cur << n if not cur.nil?
        cur = n
      when ")"
        cur = stack.pop
      else
        cur << token.to_sym
      end
    end
    return cur
  end

  # P ::= "(" "lambda" "(" id ")" e ")"
  def eval_program(ast, *args)
    @var_tables.push({})
    ex = ast[2]
    arg_labels = ast[1]
    arg_labels.zip(args).each{|label, v| @var_tables[-1][label] = v}
    eval_ex(ex)
  ensure
    @var_tables.pop
  end

  def ast_size(ast)
    case ast
    when Numeric, Symbol
      1
    when Array
      method = ast.first
      case method
      when :lambda
        1 + ast_size(ast[2])
      when :if0
        1 + ast_size(ast[1]) + ast_size(ast[2]) + ast_size(ast[3])
      when :fold
        2 + ast_size(ast[1]) + ast_size(ast[2]) + ast_size(ast[3].last)
      when *OP1
        1 + ast_size(ast[1])
      when *OP2
        1 + ast_size(ast[1]) + ast_size(ast[2])
      end
    else
      raise "unexpected ast: #{ast}"
    end
  end

  def op(ast)
    _op(ast).uniq
  end

  private
  #  expression e ::= "0" | "1" | id
  #               | "(" "if0" e e e ")"
  #               | "(" "fold" e e "(" "lambda" "(" id id ")" e ")" ")"
  #               | "(" op1 e ")"
  #               | "(" op2 e e ")"
  #           op1 ::= "not" | "shl1" | "shr1" | "shr4" | "shr16"
  #           op2 ::= "and" | "or" | "xor" | "plus" 
  #           id  ::= [a-z]+
  def eval_ex(e)
    case e
    when Symbol
      value = @var_tables.reverse_each.find{|var| break var[e] if var[e] }
      raise "undefined variable: #{e}" if value.nil?
      return value
    when Array
      method = e.first
      case method
      when :if0
        if0(e[1], e[2], e[3])
      when :fold
        fold(e[1], e[2], e[3])
      when *OP1
        send(method, e[1])
      when *OP2
        send(method, e[1], e[2])
      else
        raise "unexpected expression method: #{method}"
      end
    when Numeric
      e
    else
      raise "unexpected expression: #{e}"
    end
  end

  # "(" "if0" e1 e2 e3 ")"
  def if0(e1, e2, e3)
    if eval_ex(e1) == 0
      return eval_ex(e2)
    else
      return eval_ex(e3)
    end
  end

  # "(" "fold" e e "(" "lambda" "(" id id ")" e ")" ")"
  def fold(e1, e2, p3)
    arg1 = eval_ex(e1)
    bytes = [arg1].pack("Q").bytes.to_a
    return bytes.inject(eval_ex(e2)) do |res, byte|
      eval_program(p3, byte, res)
    end
  end

  # (" not e ")"
  def not(e)
    ~eval_ex(e)
  end

  # (" shl1 e ")"
  def shl1(e)
    eval_ex(e) << 1
  end

  # (" shr1 e ")"
  def shr1(e)
    eval_ex(e) >> 1
  end

  # (" shr4 e ")"
  def shr4(e)
    eval_ex(e) >> 4
  end

  # (" shr16 e ")"
  def shr16(e)
    eval_ex(e) >> 16
  end

  # (" and e1 e2 ")"
  def and(e1, e2)
    eval_ex(e1) & eval_ex(e2)
  end

  # "(" or e1 e2 ")"
  def or(e1, e2)
    eval_ex(e1) | eval_ex(e2)
  end

  # "(" xor e1 e2 ")"
  def xor(e1, e2)
    eval_ex(e1) ^ eval_ex(e2)
  end

  # "(" plus e1 e2 ")"
  def plus(e1, e2)
    eval_ex(e1) + eval_ex(e2)
  end

  def _op(ast)
    case ast
    when Numeric, Symbol
      []
    when Array
      method = ast.first
      case method
      when :lambda
        if ast[2].is_a?(Array) && ast[2].first == :fold
          [:tfold] + _op(ast[2][3].last)
        else
          _op(ast[2])
        end
      when :if0
        [:if0] + _op(ast[1]) + _op(ast[2]) + _op(ast[3])
      when :fold
        [:fold] + _op[ast[1]] + _op(ast[2]) + _op(ast[3].last)
      when *OP1
        [method] + _op(ast[1])
      when *OP2
        [method] + _op(ast[1]) + _op(ast[2])
      end
    else
      raise "unexpected ast: #{ast}"
    end
  end
end
