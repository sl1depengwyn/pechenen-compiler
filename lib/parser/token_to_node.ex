defmodule Parser do
  def tokens_to_nodes(tokens) do
    tokens
    |> Enum.map(&token_to_node/1)
  end

  defp token_to_node(%Lexer.Token{value: value, type: type, line: line, column: column}) do
    case type do
      :atom -> %Parser.NodeValue{value: String.to_existing_atom(value), line: line, column: column}
      :boolean -> %Parser.NodeValue{value: value, line: line, column: column}
      :integer -> %Parser.NodeValue{value: String.to_integer(value), line: line, column: column}
      :float -> %Parser.NodeValue{value: String.to_float(value), line: line, column: column}
      :liter -> %Parser.NodeValue{value: String.strip(value, "\""), line: line, column: column}
      _ -> raise "Unknown token type: #{type}"
    end
  end
end
