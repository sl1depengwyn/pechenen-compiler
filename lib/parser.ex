defmodule Parser do
  alias Parser.Node
  alias Lexer.Token

  @spec parse([Token.t()]) :: {:error, any} | {:ok, [Node.t()]}
  def parse(tokens) do
    :parser.parse(Enum.map(tokens, fn token -> {token.type, token} end))
  end
end
