defmodule PechenenCompilerTest do
  use ExUnit.Case
  alias PechenenInterpreter

  describe "PechenenInterpreter" do
    test "lambda call as function name" do
      assert_raise RuntimeError, "Error in Ln 0, Col 0: lambda_function/3 is not defined", fn ->
        PechenenInterpreter.interpret("((lambda '(p) (cond (less p 0) 'plus 'minus)) +1 1 2)")
      end

      assert {-1, _state} =
               PechenenInterpreter.interpret(
                 "(((lambda '(p) (cond (less p 0) 'plus 'minus)) +1) 1 2)"
               )
    end

    test "lambda" do
      assert {{[:p], _function}, _state} =
               PechenenInterpreter.interpret("(lambda '(p) (cond (less p 0) 'plus 'minus))")
    end

    test "setq lambda" do
      assert {4, %{scope: %{fun: {[:a, :b], _}}}} =
               PechenenInterpreter.interpret("(setq fun (lambda '(a b) (plus a b))) (fun 1 3)")
    end
  end
end
