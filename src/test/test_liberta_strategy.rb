class Solver
  class TestLibertaStrategy < Test::Unit::TestCase
=begin
    test "solve_if0で正しい戻り値が得られるか？" do
      ls = LibertaStrategy.new(
        11, ["and", "if0", "plus", "shr16"].map(&:to_sym),
        nil, nil)
      res = ls.solve_if0(
        BV::Node.get(:not),
        ["and", "if0", "plus", "shr16"].map(&:to_sym),
        [0,0xff,0xffff,0xffffffff],
        [0x1, 0x1, 0x1, 0x1],
      )
      assert_equal(
        [[:and, :plus, :shr16], [0,0xff,0xffff,0xffffffff], [0, 0, 0, 0]],
        res[1..-1])
      assert_equal([:if0, [], 1, :a], res[0].to_a)

      ls = LibertaStrategy.new(
        14, ["and", "if0", "plus", "shr16"].map(&:to_sym),
        nil, nil)
      res = ls.solve_if0(
        BV::Node.get(:not),
        ["if0", "and", "if0", "plus", "shr16"].map(&:to_sym),
        [0,0xff,0xffff,0xffffffff],
        [0,0xff,0xffff,0xffffffff],
      )
      assert_equal(
        [[:and, :if0, :plus, :shr16], [0,0xff,0xffff,0xffffffff], [0, 0, 0, 0]],
        res[1..-1])
      assert_equal([:if0, [], :a, 1], res[0].to_a)
    end

    test "solve_opで正しい戻り値が得られるか？" do
      ls = LibertaStrategy.new(
        11, ["and", "if0", "plus", "shr16"].map(&:to_sym),
        nil, nil)
      res = ls.solve_op(
        BV::Node.get(:not),
        ["and", "if0", "plus", "shr16"].map(&:to_sym),
        [0x0, 0xff, 0xffff, 0xffffff],
        [0x0, 0x0, 0x0, 0xFF],
      )
      assert_equal(
        [[:and, :if0, :plus], [0, 255, 65535, 16777215], [0, 255, 65535, 16777215]],
        res[1..-1])
      assert_equal([:shr16, []], res[0].to_a)

      ls = LibertaStrategy.new(
        11, ["and", "if0", "plus", "shr16"].map(&:to_sym),
        nil, nil)
      res = ls.solve_op(
        BV::Node.get(:not),
        ["and", "if0", "plus", "shr16"].map(&:to_sym),
        [0x0, 0xff, 0xffff, 0xffffff],
        [0x0, 0x1, 0x1, 0x1],
      )
      assert_equal(
        [[:if0, :plus, :shr16], [0, 255, 65535, 16777215], [1, 1, 1, 1]],
        res[1..-1])
      assert_equal([:and, [], :a], res[0].to_a)
    end

    test "size12, op重複もちろんあり" do
      ns = LibertaStrategy.new(
        12,  ["if0", "not", "plus", "shr4", "xor"].map(&:to_sym),
        [0x69589addb1198b, 0xd06d11b52fc209, 0x8f65e83e5513d2],
        [0xFFF96A765224EE67, 0xFFF2F92EE4AD03DF, 0xFFF709A17C1AAEC2])
      assert_equal(
        "(lambda (a) (not (shr4 (if0 (xor (shr4 (plus 0 0)) 0) a 1))))",
        ns.try_solve)
    end

    test "size13" do
      ns = LibertaStrategy.new(
        13,  ["and", "if0", "or", "shl1", "shr1", "shr4"].map(&:to_sym),
        [0x0, 0xff, 0xffff, 0xffffff],
        [0, 0xFE, 0xFFFE, 0xFFFFFE])
      assert_equal(
        "(lambda (a) (and (shl1 (if0 (or (shr1 (shr4 (shl1 0))) 0) a 1)) a))",
        ns.try_solve)
    end

    test 'size12, rootがnilになってエラーになる' do
      ns = LibertaStrategy.new(
        12,  ["if0", "or", "plus", "shr4"].map(&:to_sym),
        [0x0,0xffffffffffffff,0xb460278598e924,0x80d2fcb4018cdf],
        [0x0, 0xFFFFFFFFFFFF, 0xB460278598E9, 0x80D2FCB4018C])
      assert_equal(
        "(lambda (a) (shr4 (shr4 (if0 (plus (or (shr4 0) 0) 0) a 1))))",
        ns.try_solve)
    end
=end

    test 'size15, 解けるはずだが解けない' do
      ns = LibertaStrategy.new(
        15,  ["and", "if0", "or", "plus", "shr1", "xor"].map(&:to_sym),
        [0xffffffffffffff, 0x1, 0xba906563fdfad9, 0x81e34d07071cb9],
        [0x007FFFFFFFFFFFFF, 0x1, 0x005D4832B1FEFD6C, 0x0040F1A683838E5C])
      assert_equal(
        "(lambda (a) (shr1 (or (plus (if0 (and (shr1 (xor 0 a)) a) a 0) a) 0)))",
        ns.try_solve)
    end
  end
end
