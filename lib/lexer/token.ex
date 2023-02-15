defmodule Lexer.Token do
  @types ~w(atom liter operator)a

  @type t :: %__MODULE__{
          value: String.t() | boolean() | integer() | float(),
          type: type()
        }

  @typep type ::
           unquote(
             @types
             |> Enum.map(&inspect/1)
             |> Enum.join(" | ")
             |> Code.string_to_quoted!()
           )
  @enforce_keys [:value, :type, :column, :line]
  defstruct [:value, :type, :column, :line]
end
