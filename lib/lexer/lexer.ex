defmodule Lexer.Lexer do
  alias Lexer.Token
  alias Lexer.State

  def parse(code) when is_binary(code) do
    {:ok, []}
  end

  def parse(_) do
    {:error, "ALARM!"}
  end

  defp do_parse(
         <<value::binary-size(1)>> <> code,
         %State{column: column, line: line} = state,
         acc
       )
       when value in ["(", ")"] do
    do_parse(code, %{state | column: column + String.length(value)}, [
      %Token{value: value, type: :operator, column: column, line: line} | acc
    ])
  end

  defp do_parse("false" <> code, %State{column: column, line: line} = state, acc) do
    do_parse(code, %{state | column: column + 5}, [
      %Token{value: false, type: :liter, column: column, line: line} | acc
    ])
  end

  defp do_parse(
         "true" <> code,
         %State{column: column, line: line} = state,
         acc
       ) do
    do_parse(code, %{state | column: column + 4}, [
      %Token{value: true, type: :liter, column: column, line: line} | acc
    ])
  end

  defp do_parse(
         "null" <> code,
         %State{column: column, line: line} = state,
         acc
       ) do
    do_parse(code, %{state | column: column + 4}, [
      %Token{value: nil, type: :liter, column: column, line: line} | acc
    ])
  end

  defp do_parse(<<n, code::binary>>, %State{column: _column, line: line} = state, acc)
       when n in '\n' do
    do_parse(code, %{state | column: 0, line: line + 1}, acc)
  end

  defp do_parse(" " <> code, %State{column: column, line: _line} = state, acc) do
    do_parse(code, %{state | column: column + 1}, [
      acc
    ])
  end

  defp do_parse(
         <<value::binary-size(1)>> <> _ = code,
         %State{column: column, line: line} = state,
         acc
       )
       when value in ~w(0 1 2 3 4 5 6 7 8 9 + -) do
    {value, remain} = parse_liter(code)

    do_parse(remain, %{state | column: column + String.length(value)}, [
      %Token{value: value, type: :liter, column: column, line: line} | acc
    ])
  end

  defp do_parse(
         code,
         %State{column: column, line: line} = state,
         acc
       ) do
    parse_atom(code)
  end

  defp parse_atom(_) do
  end

  defp parse_liter(<<value::binary-size(1)>> <> remains = code, acc \\ "")
       when value in ~w(0 1 2 3 4 5 6 7 8 9 + -) do
    case value do
      sign when sign in ~w(+ -) ->
        {integer, remains} = parse_integer(remains)
        parse_liter(remains, sign <> integer)

      _ ->
        {integer, remains} = parse_integer(code)
        parse_liter(remains, integer)
    end
  end

  defp parse_liter("." <> remains, acc) do
    {integer, remains} = parse_integer(remains)
    {acc <> "." <> integer, remains}
  end

  defp parse_liter(remains, acc) do
    {acc, remains}
  end

  defp parse_integer(code, acc \\ "")

  defp parse_integer(<<value::binary-size(1)>> <> remains, acc)
       when value in ~w(0 1 2 3 4 5 6 7 8 9) do
    parse_integer(remains, acc <> value)
  end

  defp parse_integer(remains, acc) do
    {acc, remains}
  end
end
