defmodule Interpreter do
  alias Parser.Node

  def initial_state do
    %{
      plus:
        {[:a, :b],
         fn
           %{a: a, b: b} when is_number(a) and is_number(b) -> a + b
           _ -> raise {:error, "Both plus arguments should be numbers"}
         end}
    }
  end

  @spec interpret(ast: [Node.t()]) :: any()
  def interpret(ast) do
    {:ok,
     Enum.reduce(ast, %{}, fn node, acc ->
       {value, state} = interpret_node(node, acc)
       IO.inspect(value)
       state
     end)}
  end

  # @spec interpret_node(Node.t()) :: nil
  # def interpret_node({%NodeValue{}, children})

  def interpret_node(%{value: value}, state) do
    {value, state}
  end

  def interpret_node({%{value: value} = node_value, children}, state)
      when is_atom(value) do
    interpret_function_call(node_value, children, state)
  end

  def interpret_node({%{} = node_value, _}, _state) do
    raise {:error, "Illegal function name", node_value}
  end

  def interpret_function_call(%{value: arithmetic_operation}, args, state)
when arithmetic_operation in [:plus, :minus, :times, :divide] do


    with {a, _state} when is_number(a) <- interpret_node(a, state),
         {b, _state} when is_number(b) <- interpret_node(b, state) do
      {apply(__MODULE__, arithmetic_operation, [a, b]), state}
    else
      argument ->
        nil
    end
  end

  def interpret_function_call(%{value: :func}, [name, args, body], state) do
    # func = fn

    # Map.put(state, name, func)

    with {a, _state} when is_number(a) <- interpret_node(a, state),
         {b, _state} when is_number(b) <- interpret_node(b, state) do
      {apply(__MODULE__, arithmetic_operation, [a, b]), state}
    else
      argument ->
        raise {:error, "Both plus arguments should be numbers", argument}
    end
  end

  def plus(a, b), do: a + b
  def minus(a, b), do: a - b
  def times(a, b), do: a * b
  def divide(a, b), do: a / b

  #   ( plus Element Element)
  # ( minus Element Element )
  # ( times Element Element )
  # ( divide Element Element )
end
