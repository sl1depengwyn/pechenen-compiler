defmodule Parser do
  alias Parser.Node

  @spec parse(binary) :: {:error, any} | {:ok, Node.t()}
  def parse(string) do
    {:ok, tokens} = Lexer.scan(string)

    :parser.parse(Enum.map(tokens, fn token -> {token.type, token} end))
  end
end
