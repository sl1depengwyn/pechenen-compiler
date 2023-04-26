defmodule Interpreter do
  alias Parser.Node

  def initial_state do
    %{
      scope:
        [plus: &Kernel.+/2, minus: &Kernel.-/2, times: &Kernel.*/2, divide: &Kernel.//2]
        |> Map.new(fn {name, func} ->
          {name,
           {[:a, :b],
            fn
              %{scope: %{a: a, b: b}} when is_number(a) and is_number(b) ->
                func.(a, b)

              %{service: %{line: line, column: column}} ->
                raise "Error in Ln #{line}, Col #{column}: Both #{name} arguments should be numbers"
            end}}
        end),
      service: %{line: 0, column: 0}
    }
  end

  @spec interpret(ast: [Node.t()]) :: any()
  def interpret(ast) do
    {:ok,
     Enum.reduce(ast, initial_state(), fn node, acc ->
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

  def interpret_function_call(
        %{value: arithmetic_operation, line: line, column: column},
        args,
        state
      )
      when arithmetic_operation in [:plus, :minus, :times, :divide] do
    with {func_args, function} <- state.scope[arithmetic_operation],
         {:number_of_args, true} <- {:number_of_args, length(args) == length(func_args)} do
      {args
       |> Enum.map(&interpret_node(&1, state))
       |> Enum.zip(func_args)
       |> Enum.reduce(state, fn {{val, _state}, arg_name}, state ->
         put_in(state, [:scope, arg_name], val)
       end)
       |> put_in([:service, :line], line)
       |> put_in([:service, :column], column)
       |> function.(), state}
    else
      {:number_of_args, false} ->
        raise "Error in Ln #{line}, Col #{column}: #{arithmetic_operation}/#{length(args)} is not defined"
    end
  end

  # def interpret_function_call(%{value: :func}, [name, args, body], state) do
  #   # func = fn

  #   # Map.put(state, name, func)

  #   with {a, _state} when is_number(a) <- interpret_node(a, state),
  #        {b, _state} when is_number(b) <- interpret_node(b, state) do
  #     {apply(__MODULE__, arithmetic_operation, [a, b]), state}
  #   else
  # nil ->
  #   raise "Error in Ln #{line}, Col #{column}: Function #{arithmetic_operation} not defined"
  #     argument ->
  #       raise {:error, "Both plus arguments should be numbers", argument}
  #   end
  # end

  #   ( plus Element Element)
  # ( minus Element Element )
  # ( times Element Element )
  # ( divide Element Element )
end
