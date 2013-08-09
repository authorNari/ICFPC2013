class TestBV < Test::Unit::TestCase
  def setup
    @bv = BV.new
  end

  should "parse結果の構文木が正しいこと" do
    expect = [:lambda, [:x], [:if0, [:and, [:not, :x], :x], 1, :x]]
    assert_equal expect, @bv.parse("(lambda (x) (if0 (and (not x) x) 1 x))")
  end

"(lambda (x_7021) (fold x_7021 0 (lambda (x_7021 x_7022) (plus (shr4 (shr16 x_7022)) x_7021))))"
  should "eval_programの結果が正しいこと" do
    prog = "(lambda (x) (fold x 0 (lambda (y z) (or y z))))"
    expect = 0x00000000000000ff
    assert_equal expect, @bv.eval_program(@bv.parse(prog), 0x1122334455667788)

    prog = "(lambda (x_7021) (fold x_7021 0 (lambda (x_7021 x_7022) (plus (shr4 (shr16 x_7022)) x_7021))))"
    assert_equal 0x11, @bv.eval_program(@bv.parse(prog), 0x1122334455667788)
    assert_equal 0x00, @bv.eval_program(@bv.parse(prog), 0x22334455667788)
    

    prog = "(lambda (x) (and (plus (not x) 0) 1))"
    expect = 0x0000000000000001
    assert_equal expect, @bv.eval_program(@bv.parse(prog), 0)
    assert_equal expect, @bv.eval_program(@bv.parse(prog), 10)
    assert_equal expect, @bv.eval_program(@bv.parse(prog), 100)

    prog = "(lambda (x_27071) (fold (shr16 (shl1 (xor x_27071 1))) x_27071 (lambda (x_27072 x_27073) (shr4 (plus x_27072 x_27073)))))"
    assert_equal 0, @bv.eval_program(@bv.parse(prog), 9)

    prog = "(lambda (x_45941) (fold (shr16 (xor (if0 (not (or x_45941 0)) (shr16 x_45941) 1) x_45941)) x_45941 (lambda (x_45942 x_45943) (xor x_45943 (not x_45942)))))"
    assert_equal 0x00223344556677EE, @bv.eval_program(@bv.parse(prog), 0x22334455667788)

    prog = "(lambda (x_46496) (or (xor (shr1 (or (shr4 (and (plus (or (not x_46496) (and 1 (shl1 (shr16 (if0 (and (shr16 (shl1 (shl1 x_46496))) x_46496) 1 0))))) 1) x_46496)) x_46496)) 0) 0))"
    ast = @bv.parse(prog)
    assert_equal 0x001119A22AB33BC4, @bv.eval_program(ast, 0x22334455667788)
  end

  should "ast_sizeのサイズが正しいこと" do
    prog = "(lambda (x_33818) (fold (plus (and (shr16 (shl1 1)) 1) 1) x_33818 (lambda (x_33819 x_33820) (or x_33819 (shr4 x_33820)))))"
    ast = @bv.parse(prog)
    assert_equal 15, @bv.ast_size(ast)

    prog = "(lambda (x_6410) (xor (or (shl1 1) x_6410) x_6410))"
    ast = @bv.parse(prog)
    assert_equal 7, @bv.ast_size(ast)

    prog = "(lambda (x_47225) (or (if0 (shr1 x_47225) (plus (if0 (xor (shr16 (shl1 (shl1 (shr16 (shl1 (or (shl1 1) (shr1 (and (shr16 (plus x_47225 0)) (shl1 0))))))))) 1) 0 0) 0) x_47225) 1))"
    ast = @bv.parse(prog)
    assert_equal 30, @bv.ast_size(ast)
  end
end
