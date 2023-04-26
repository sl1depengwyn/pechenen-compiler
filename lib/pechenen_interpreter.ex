defmodule PechenenInterpreter do
  alias Lexer
  alias Parser
  alias Interpreter

  def interpret(source) do
    with {:lexer, {:ok, tokens}} <- {:lexer, Lexer.scan(source)},
         {:parser, {:ok, ast}} <- {:parser, Parser.parse(tokens)},
         {:interpreter, {:ok, result}} <- {:interpreter, Interpreter.interpret(ast)} do
      IO.inspect(result)
    end
  end
end
