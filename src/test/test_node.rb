class BV
  class TestNode < Test::Unit::TestCase
    context "If0クラス" do
      should "assignable_exp_maxは3であること" do
        assert_equal 3, Node.get(:if0).assignable_exp_max
      end

      should "子供にlambdaはもたない" do
        assert_equal false, Node.get(:if0).has_lambda?
      end

      should "push_exp後のto_aは[:if0 e1 e2 e3]の形式であること" do
        if0 = Node.get(:if0)
        true while if0.push_exp(0)
        assert_equal [:if0, 0, 0, 0], if0.to_a
      end

      should "すべてexpがassignされたらassigned?はtrueになる" do
        if0 = Node.get(:if0)
        assert_equal false, if0.assigned?
        true while if0.push_exp(0)
        assert_equal [:if0, 0, 0, 0], if0.to_a
      end
    end

    context "Lambdaクラス" do
      should "assignable_exp_maxは1であること" do
        assert_equal 1, Node.get(:lambda).assignable_exp_max
      end

      should "lambdaはもっていない" do
        assert_equal false, Node.get(:lambda).has_lambda?
      end

      should "push_exp後のto_aは[:lambda [id] e1]の形式であること" do
        lambda = Node.get(:lambda)
        true while lambda.push_exp(0)
        assert_equal [:lambda, [:a, :b], 0], lambda.to_a
      end

      should "すべてexpがassignされたらassigned?はtrueになる" do
        lambda = Node.get(:lambda)
        assert_equal false, lambda.assigned?
        true while lambda.push_exp(0)
        assert_equal true, lambda.assigned?
      end
    end

    context "TFoldクラス" do
      should "assignable_exp_maxは1であること" do
        assert_equal 1, Node.get(:tfold).assignable_exp_max
      end

      should "lambdaはもってない" do
        # TFoldは特別扱い
        assert_equal false, Node.get(:tfold).has_lambda?
      end

      should "push_expのto_aは[:lambda, [:x], [:fold, :x, 0, [:lambda, [:x, :y], e1]]]の形式であること" do
        node = Node.get(:tfold)
        true while node.push_exp(0)
        assert_equal [:lambda, [:a], [:fold, :a, 0, [:lambda, [:a, :b], 0]]], node.to_a
      end

      should "すべてexpがassignされたらassigned?はtrueになる" do
        node = Node.get(:tfold)
        assert_equal false, node.assigned?
        true while node.push_exp(0)
        assert_equal true, node.assigned?
      end
    end

    context "Foldクラス" do
      should "assignable_exp_maxは2であること" do
        assert_equal 2, Node.get(:fold).assignable_exp_max
      end

      should "lambdaはもっている" do
        assert_equal true, Node.get(:fold).has_lambda?
      end

      should "push_exp後のto_aは[:fold, e1, e2, [:lambda, [id, id], e3]]の形式であること" do
        node = Node.get(:fold)
        true while node.push_exp(0)
        true while node.lambda.push_exp(0)
        assert_equal [:fold, 0, 0, [:lambda, [:a, :b], 0]], node.to_a
      end

      should "すべてexpがassignされたらassigned?はtrueになる" do
        node = Node.get(:fold)
        assert_equal false, node.assigned?
        true while node.push_exp(0)
        true while node.lambda.push_exp(0)
        assert_equal true, node.assigned?
        assert_equal true, node.lambda.assigned?
      end

      should "rootはFoldになる" do
        node = Node.get(:fold)
        assert_equal false, node.assigned?
        true while node.push_exp(0)
        lambda = node.lambda
        true while lambda.push_exp(0)
        assert_equal Node::Fold, node.root.class
        assert_equal Node::Fold, lambda.root.class
      end

      should "tree_sizeは子供の分のサイズも合計して返す" do
        root = Node.get(:tfold)
        node = root.push_exp(:and)
        node.push_exp(:not).push_exp(0)
        assert_equal BV.new.ast_size(root.to_a), root.size

        if0 = node.push_exp(:if0)
        assert_equal BV.new.ast_size(root.to_a), root.size

        fold = if0.push_exp(:fold)
        fold.push_exp(0)
        fold.push_exp(0)
        assert_equal BV.new.ast_size(root.to_a), root.size

        assert_equal BV.new.ast_size(root.to_a), root.size
        fold.lambda.push_exp(0)
        if0.push_exp(0)
        if0.push_exp(:a)
        assert_equal BV.new.ast_size(root.to_a), root.size

        assert_equal BV.new.ast_size(root.to_a), root.size
      end
    end

    context "OP1クラス" do
      should "assignable_exp_maxは1であること" do
        assert_equal 1, Node.get(:not).assignable_exp_max
      end

      should "lambdaはもっていない" do
        assert_equal false, Node.get(:shl1).has_lambda?
      end

      should "push_exp後のto_aは[op, e1]の形式であること" do
        node = Node.get(:shr16)
        true while node.push_exp(:x)
        assert_equal [:shr16, :x], node.to_a
      end
    end

    context "OP2クラス" do
      should "assignable_exp_maxは2であること" do
        assert_equal 2, Node.get(:or).assignable_exp_max
      end

      should "lambdaはもっていない" do
        assert_equal false, Node.get(:xor).has_lambda?
      end

      should "push_exp後のto_aは[op, e1]の形式であること" do
        node = Node.get(:and)
        assert_equal Node::OP2, node.class
        node.push_exp(:x)
        node.push_exp(:y)
        assert_equal [:and, :x, :y], node.to_a
      end
    end
  end
end
