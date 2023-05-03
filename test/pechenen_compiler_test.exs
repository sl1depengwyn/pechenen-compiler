defmodule PechenenCompilerTest do
  use ExUnit.Case
  alias PechenenInterpreter

  describe "PechenenInterpreter" do
    test "lambda call as function name" do
      # assert_raise RuntimeError, "Error in Ln 0, Col 0: lambda_function/3 is not defined", fn ->
      #   PechenenInterpreter.interpret(
      #     ""
      #   )
      # end
      # (prog () ((lambda (p) (cond (less p 0) 'plus 'minus)) +1 1 2))
      assert {-1, _state} =
               PechenenInterpreter.interpret(
                 "(prog () (((lambda (p) (cond (less p 0) 'plus 'minus)) +1) 1 2))"
               )
    end

    test "lambda" do
      assert {{[:p], _function}, _state} =
               PechenenInterpreter.interpret(
                 "(prog () (lambda (p) (cond (less p 0) 'plus 'minus)))"
               )
    end

    test "while" do
      assert {:null,
              %{
                scope: %{
                  a: 0
                }
              }} =
               PechenenInterpreter.interpret(
                 "(setq a 5)  (prog () (while (greater a 0) (setq a (minus a 1))))"
               )
    end

    test "setq lambda" do
      assert {4, %{scope: %{fun: {[:a, :b], _}}}} =
               PechenenInterpreter.interpret(
                 "(setq fun (lambda (a b) (plus a b))) (prog () (fun 1 3))"
               )
    end

    test "recursion" do
      assert {5, _state} =
               PechenenInterpreter.interpret("""
               (func Fibonacci (n) (
                 cond (less n 2)
                   n
                   (plus (Fibonacci (minus n 1)) (Fibonacci (minus n 2))))
               )

               (prog () (Fibonacci 5))
               """)
    end

    test "return" do
      assert {:null,
              %{
                scope: %{
                  a: 0
                }
              }} =
               PechenenInterpreter.interpret(
                 "(setq a 5) (prog () (while 'true (cond (lesseq a 0) (return true) (setq a (minus a 1)))))"
               )
    end

    test "break" do
      assert {:null,
              %{
                scope: %{
                  a: 0
                }
              }} =
               PechenenInterpreter.interpret(
                 "(setq a 5) (prog () (while 'true (cond (lesseq a 0) (break) (setq a (minus a 1)))))"
               )
    end

    test "cli args" do
      assert {5, _state} =
               PechenenInterpreter.interpret(
                 "(prog (a) a)",
                 [5]
               )
    end

    test "from file" do
      assert {5, _state} = PechenenInterpreter.main(["test/fixture/golden.plisp", "5"])
    end

    test "from file" do
      assert {5, _state} = PechenenInterpreter.main(["test/fixture/constructAsc.plisp", "5"])
    end

    # test "return on the top level" do
    #   assert {5, _state} = PechenenInterpreter.interpret("(return 5) (return 6)")
    # end

    test "isnull" do
      assert {true, _state} = PechenenInterpreter.interpret("(prog () (isnull 'null))")
    end
  end
end
