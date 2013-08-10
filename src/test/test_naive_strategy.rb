class Solver
  class TestNaiveStrategy < Test::Unit::TestCase
    should "size10, op重複なしの組み合わせが解ける" do
      ns = NaiveStrategy.new(
        10, [:and, :if0, :shr16, :xor],
        [0x1, 0x2, 0x3, 0x4], [0x0, 0x2, 0x0, 0x4])
      assert_equal(
        [:lambda, [:a], [:if0, [:and, [:xor, [:shr16, 0], :a], 1], :a, 0]],
        ns.try_solve)
    end

    should "size5, op重複なしの組み合わせが解ける" do
      ns = NaiveStrategy.new(
        5, [:plus, :shr16],
        [0x1, 0x2, 0x3, 0x4, 0x112233],
        [0x0, 0x0, 0x0, 0x0, 0x11])
      assert_equal(
        [:lambda, [:a], [:plus, [:shr16, :a], 0]],
        ns.try_solve)
    end
  end
end
