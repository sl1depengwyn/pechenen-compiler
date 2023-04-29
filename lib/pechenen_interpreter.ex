defmodule PechenenInterpreter do
  alias Lexer
  alias Parser
  alias Interpreter

  def main(args) do
    case args |> Enum.map(&parse_arg/1) do
      [filename | program_args] ->
        source = File.read!(filename)
        {value, _state} = interpret(source, program_args)
        IO.puts(to_string(value))

      _ ->
        raise "No source filename provided"
    end
  end

  def interpret(source, args \\ []) do
    with {:lexer, {:ok, tokens}} <- {:lexer, Lexer.scan(source)},
         {:parser, {:ok, ast}} <- {:parser, Parser.parse(tokens) |> IO.inspect(label: "ast")},
         {:interpreter, {:ok, result}} <- {:interpreter, Interpreter.interpret(ast, args)} do
      IO.inspect(result, label: "hererer")
    end
  end

  def parse_arg(arg) do
    {integer_arg, integer_remain} =
      case Integer.parse(arg) do
        :error -> {nil, "str"}
        int -> int
      end

    {float_arg, float_remain} =
      case Float.parse(arg) do
        :error -> {nil, "str"}
        float -> float
      end

    cond do
      integer_remain == "" -> integer_arg
      float_remain == "" -> float_arg
      true -> arg
    end
  end
end
