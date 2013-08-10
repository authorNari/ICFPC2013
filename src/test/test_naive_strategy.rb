class Solver
  class TestNaiveStrategy < Test::Unit::TestCase
    should "重複可能数の計算が正しいか？" do
      ns = NaiveStrategy.new(
        26, ["and", "if0", "not", "or", "shl1", "shr1", "shr4", "tfold", "xor"].map(&:to_sym), nil, nil)
      assert_equal [nil, 8, 4, 3], ns.send(:calc_e_dep_max)

      ns = NaiveStrategy.new(
        12, [:if0, :not, :or, :plus, :shl1, :shr16], nil, nil)
      assert_equal [nil, 1, 1, 1], ns.send(:calc_e_dep_max)

      ns = NaiveStrategy.new(
        8, [:plus, :shl1, :shr1, :shr16], nil, nil)
      assert_equal [nil, 2, 1], ns.send(:calc_e_dep_max)

      ns = NaiveStrategy.new(
        15, [:if0, :not, :plus, :shr4, :tfold], nil, nil)
      assert_equal [nil, 3, 2, 1], ns.send(:calc_e_dep_max)

      ns = NaiveStrategy.new(
        10, [:and, :if0, :shr16, :xor], nil, nil)
      assert_equal [nil, 1, 1, 1], ns.send(:calc_e_dep_max)

      ns = NaiveStrategy.new(
        5, [:plus, :shr16], nil, nil)
      assert_equal [nil, 1, 1], ns.send(:calc_e_dep_max)
    end

    should "size10, op重複あり, tfoldの組み合わせが解ける" do
      # id: pVv6oAP4fOAutAfwJ7Ie6dta
      ns = NaiveStrategy.new(
        10,
        [:plus, :shr4, :tfold],
        [1, 2, 3, 4, 0x112233, 0xF000000000000000], [0x0, 0x0, 0x0, 0x0, 0x0, 0x0F])
      assert_equal(
        "(lambda (a) (fold a 0 (lambda (a b) (shr4 (plus (shr4 0) a)))))",
        ns.try_solve)
    end

    should "size10, op重複なしの組み合わせが解ける" do
      ns = NaiveStrategy.new(
        10, [:and, :if0, :shr16, :xor],
        [0x1, 0x2, 0x3, 0x4], [0x0, 0x2, 0x0, 0x4])
      assert_equal(
        "(lambda (a) (if0 (and (xor (shr16 0) a) 1) a 0))",
        ns.try_solve)
    end

    should "size5, op重複なしの組み合わせが解ける" do
      ns = NaiveStrategy.new(
        5, [:plus, :shr16],
        [0x1, 0x2, 0x3, 0x4, 0x112233],
        [0x0, 0x0, 0x0, 0x0, 0x11])
      assert_equal(
        "(lambda (a) (plus (shr16 a) 0))",
        ns.try_solve)
    end

    should "size5, op重複なし, notの組み合わせが解ける" do
      ns = NaiveStrategy.new(
        5,  ["not", "shl1", "shr4"].map(&:to_sym),
        [0xacd1117daf242a],
        [0xFFEA65DDD04A1B7B])
      assert_equal(
        "(lambda (a) (not (shl1 (shr4 a))))",
        ns.try_solve)
    end
  end
end
