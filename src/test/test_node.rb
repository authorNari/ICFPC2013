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
    end

    context "Lambdaクラス" do
      should "assignable_exp_maxは1であること" do
        assert_equal 1, Node.get(:lambda).assignable_exp_max
      end

      should "assignable_id_maxは2であること" do
        assert_equal 2, Node.get(:lambda).assignable_id_max
      end

      should "lambdaはもっていない" do
        assert_equal false, Node.get(:lambda).has_lambda?
      end

      should "push_exp, push_ids後のto_aは[:lambda [id] e1]の形式であること" do
        lambda = Node.get(:lambda)
        true while lambda.push_exp(0)
        true while lambda.push_id(:x)
        assert_equal [:lambda, [:x, :x], 0], lambda.to_a
      end
    end

    context "TFoldクラス" do
      should "assignable_exp_maxは1であること" do
        assert_equal 1, Node.get(:tfold).assignable_exp_max
      end

      should "lambdaはもっている" do
        assert_equal true, Node.get(:tfold).has_lambda?
      end

      should "push_exp, push_ids後のto_aは[:lambda, [:x], [:fold, :x, 0, [:lambda, [:x, :y], e1]]]の形式であること" do
        node = Node.get(:tfold)
        true while node.push_exp(0)
        assert_equal [:lambda, [:x], [:fold, :x, 0, [:lambda, [:x, :y], 0]]], node.to_a
      end
    end

    context "Foldクラス" do
      should "assignable_exp_maxは2であること" do
        assert_equal 2, Node.get(:fold).assignable_exp_max
      end

      should "lambdaはもっている" do
        assert_equal true, Node.get(:fold).has_lambda?
      end

      should "push_exp, push_ids後のto_aは[:fold, e1, e2, [:lambda, [id, id], e3]]の形式であること" do
        node = Node.get(:fold)
        true while node.push_exp(0)
        lambda = Node.get(:lambda)
        true while lambda.push_exp(0)
        lambda.push_id(:x)
        lambda.push_id(:y)
        node.lambda = lambda
        assert_equal [:fold, 0, 0, [:lambda, [:x, :y], 0]], node.to_a
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
