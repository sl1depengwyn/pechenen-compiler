defmodule Lexer do
  alias Lexer.Token
  alias Lexer.State

  @delimiters [" ", ")", "\n"]

  @spec scan(String.t()) :: {:error, String.t()} | {:ok, [Token.t()]}
  def scan(code) when is_binary(code) do
    do_parse(code, %State{}, [])
  end

  def scan(code) do
    {:error, "For some reason argument of parse/1 function is not a string: #{inspect(code)}"}
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
      %Token{value: String.to_atom(value), type: :operator, column: column, line: line} | acc
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
    with {string_value, remain} <- parse_number(code) do
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
    else
      {:error, <<token::binary-size(1)>> <> _remain, acc} ->
        {:error,
         "Unexpected token: #{token} after number #{acc}. Line: #{line}, column: #{column}"}
    end
  end

  defp do_parse(
         code,
         %State{column: column, line: line} = state,
         acc
       ) do
    {string_value, remain} = parse_atom(code)

    type = if string_value in ~w(true false null), do: :liter, else: :atom

    do_parse(remain, %{state | column: column + String.length(string_value)}, [
      %Token{value: String.to_atom(string_value), type: type, column: column, line: line} | acc
    ])
  end

  defp parse_atom(code, acc \\ "")

  defp parse_atom(<<value::binary-size(1)>> <> remain, acc)
       when value not in ["+", "-", " ", "'", "(", ")"] do
    parse_atom(remain, acc <> value)
  end

  defp parse_atom(code, acc) do
    {acc, code}
  end

  defp parse_number(code, acc \\ "")

  defp parse_number(<<value::binary-size(1)>> <> remain = code, acc)
       when value in ~w(0 1 2 3 4 5 6 7 8 9 + -) do
    IO.inspect({code, acc}, label: "95")

    {sign, number} =
      case value do
        sign when sign in ~w(+ -) -> {sign, remain}
        _ -> {"", code}
      end

    with {integer, remain} <- parse_integer(number),
         {number, remain} <- parse_number(remain, integer) do
      {sign <> number, remain}
    else
      error -> error
    end
  end

  defp parse_number("." <> remain, acc) do
    IO.inspect({remain, acc}, label: "111")

    case parse_integer(remain) do
      {integer, "." <> _remain = code} -> {:error, code, acc <> "." <> integer}
      {integer, remain} -> {acc <> "." <> integer, remain}
      error -> error
    end
  end

  defp parse_number(remain, acc) do
    IO.inspect({remain, acc}, label: "120")
    {acc, remain}
  end

  defp parse_integer(code, acc \\ "")

  defp parse_integer(<<value::binary-size(1)>> <> remain, acc)
       when value in ~w(0 1 2 3 4 5 6 7 8 9) do
    parse_integer(remain, acc <> value)
  end

  defp parse_integer(<<value::binary-size(1)>> <> _remain = code, acc)
       when value in ["." | @delimiters] do
    {acc, code}
  end

  defp parse_integer("" = remain, acc) do
    {acc, remain}
  end

  defp parse_integer(remain, acc) do
    {:error, remain, acc}
  end
end
