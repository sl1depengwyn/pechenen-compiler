defmodule Parser.Node do
  alias Parser.NodeValue
  @type t :: {NodeValue.t(), [NodeValue.t() | Node.t()]}
end
