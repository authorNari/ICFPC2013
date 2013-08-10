class Solver
  class TestBinStrategy < Test::Unit::TestCase
    priority :never
    test "候補の辞書作りがうまくいくかな？" do
      bs = BinStrategy.new(
        8,  ["or", "plus", "shr16"].map(&:to_sym),
        [0xacd1117daf242a],
        [0xFFEA65DDD04A1B7B])
      bs.try_solve

      bs = BinStrategy.new(
        11, [:and, :if0, :shr16, :xor],
        [0x1, 0x2, 0x3, 0x4], [0x0, 0x2, 0x0, 0x4])
      bs.try_solve
    end
  end
end
