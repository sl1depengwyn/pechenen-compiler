defmodule Parser do
  def parse(string) do
    {:ok, tokens} = Lexer.scan(string)

    :parser.parse(
      Enum.map(tokens, fn token -> {token.type, token.value, token.line, token.column} end)
      |> IO.inspect()
    )
  end
end
