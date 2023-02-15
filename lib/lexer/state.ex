defmodule Lexer.State do
  @enforce_keys [:column, :line]
  defstruct [:column, :line]
end
