defmodule Parser.NodeValue do
  @type t :: %__MODULE__{
          value: String.t() | boolean() | integer() | float() | atom() | list(),
          line: non_neg_integer(),
          column: non_neg_integer()
        }

  @enforce_keys [:value, :column, :line]
  defstruct [:value, :column, :line]
end
