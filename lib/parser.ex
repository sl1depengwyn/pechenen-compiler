defmodule Parser do
  def parse(string) do
    {:ok, tokens} = Lexer.scan(string)

    :parser.parse(Enum.map(tokens, fn token -> {token.type, token.line, String.to_atom(token.value)} end))
  end
end
