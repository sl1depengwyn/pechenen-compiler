defmodule Parser do
  def parse(string) do
    {:ok, tokens} = Lexer.scan(string)

    :parser.parse(Enum.map(tokens, fn token -> {token.value, token.type, token.line} end))
  end
end
