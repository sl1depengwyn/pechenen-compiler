defmodule Lexer do
  alias Lexer.Token
  alias Lexer.State

  @spec parse(String.t()) :: {:error, String.t()} | {:ok, [Token.t()]}
  def parse(code) when is_binary(code) do
    do_parse(code, %State{}, [])
  end

  def parse(_) do
    {:error, "Code is not a binary"}
  end

  defp do_parse("", _state, acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp do_parse(
         <<value::binary-size(1)>> <> code,
         %State{column: column, line: line} = state,
         acc
       )
       when value in ["(", ")", "'"] do
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
    do_parse(code, %{state | column: column + 1}, acc)
  end

  defp do_parse(
         <<value::binary-size(1)>> <> _ = code,
         %State{column: column, line: line} = state,
         acc
       )
       when value in ~w(0 1 2 3 4 5 6 7 8 9 + -) do
    {string_value, remain} = parse_liter(code)

    type = if String.contains?(string_value, "."), do: Float, else: Integer

    case type.parse(string_value) do
      {numeric, ""} ->
        do_parse(remain, %{state | column: column + String.length(string_value)}, [
          %Token{value: numeric, type: :liter, column: column, line: line} | acc
        ])

      {_numeric, tail} ->
        {:error,
         "Unexpected token: #{tail} in #{inspect(type)} value. Line: #{line}, column: #{column}"}
    end
  end

  defp do_parse(
         code,
         %State{column: column, line: line} = state,
         acc
       ) do
    {string_value, remain} = parse_atom(code)

    do_parse(remain, %{state | column: column + String.length(string_value)}, [
      %Token{value: String.to_atom(string_value), type: :atom, column: column, line: line} | acc
    ])
  end

  defp parse_atom(code, acc \\ "")

  defp parse_atom(<<value::binary-size(1)>> <> remains, acc)
       when value not in ["+", "-", " ", "'", "(", ")"] do
    parse_atom(remains, acc <> value)
  end

  defp parse_atom(code, acc) do
    {acc, code}
  end

  defp parse_liter(code, acc \\ "")

  defp parse_liter(<<value::binary-size(1)>> <> remains = code, _acc)
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
