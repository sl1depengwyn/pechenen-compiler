defmodule Interpreter do
  alias Parser.Node

  @spec interpret(ast: [Node.t()]) :: any()
  def interpret(ast) do
    {:ok,
     Enum.reduce(ast, initial_state(), fn node, acc ->
       {value, state} = interpret_node(node, acc)
       IO.inspect(value, label: "value")
       state
     end)}
  end

  def initial_state do
    %{
      scope: arithmetic_functions(),
      service: %{line: 0, column: 0}
    }
  end

  def arithmetic_functions do
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
    end)
  end

  def interpret_node(node, state, return_state? \\ true)

  def interpret_node(%{value: value}, state, return_state?) when is_atom(value) do
    val = state.scope[value]

    if return_state? do
      {val, state}
    else
      val
    end
  end

  def interpret_node(%{value: value}, state, return_state?) do
    if return_state? do
      {value, state}
    else
      value
    end
  end

  def interpret_node([%{value: value} = node_value | children], state, return_state?)
      when is_atom(value) do
    {value, state} = interpret_function_call(node_value, children, state)

    if return_state? do
      {value, state}
    else
      value
    end
  end

  def interpret_node([%{} = node_value | _], _state, _return_state?) do
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
       |> Enum.map(&interpret_node(&1, state, false))
       |> Enum.zip(func_args)
       |> Enum.reduce(state, fn {val, arg_name}, state ->
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

  def interpret_function_call(%{value: :func}, [%{value: name}, args, body], state) do
    args = interpret_node(args, state, false)

    func = fn state ->
      interpret_node(body, state, false)
    end

    {nil, put_in(state, [:scope, name], {args, func})}
  end

  def interpret_function_call(%{value: :quote}, [arg], state) do
    {if(is_list(arg), do: Enum.map(arg, &take_value/1), else: take_value(arg)), state}
  end

  def interpret_function_call(%{value: :setq}, [%{value: atom}, element], state)
      when is_atom(atom) do
    {nil, put_in(state, [:scope, atom], interpret_node(element, state, false))}
  end

  def interpret_function_call(
        %{value: :setq},
        [%{value: value, line: line, column: column}, _element],
        _state
      ) do
    raise "Error in Ln #{line}, Col #{column}: #{:setq} expects first argument to be atom, got: #{value}"
  end

  def interpret_function_call(%{value: :lambda}, [args, body], state) do
    args = interpret_node(args, state, false)

    func = fn state ->
      interpret_node(body, state, false)
    end

    {{args, func}, state}
  end

  def interpret_function_call(%{value: :cond} = value, [condition, then_clause], state) do
    do_cond(value, [condition, then_clause, %{value: nil}], state)
  end

  def interpret_function_call(
        %{value: :cond} = value,
        [condition, then_clause, else_clause],
        state
      ) do
    do_cond(value, [condition, then_clause, else_clause], state)
  end

  defp do_cond(
         %{value: :cond, line: line, column: column},
         [condition, then_clause, else_clause],
         state
       ) do
    condition = interpret_node(condition, state, false)

    unless is_boolean(condition) do
      raise "Error in Ln #{line}, Col #{column}: cond expects first argument to be boolean, got: #{condition}"
    end

    if condition do
      interpret_node(then_clause, state)
    else
      interpret_node(then_clause, state)
    end
  end

  def interpret_function_call(%{value: :eval}, [arg], state) do
    # TODO check if here we need state or not
    interpret_node(arg, state, false)
  end

  def interpret_function_call(%{value: :eval, line: line, column: column}, args, _state) do
    raise "Error in Ln #{line}, Col #{column}: #{:quote}/#{length(args)} is not defined"
  end

  def interpret_function_call(%{value: function_name, line: line, column: column}, args, state) do
    with {func_args, function} <- state.scope[function_name],
         {:number_of_args, true} <- {:number_of_args, length(args) == length(func_args)} do
      {args
       |> Enum.map(&interpret_node(&1, state, false))
       |> Enum.zip(func_args)
       |> Enum.reduce(state, fn {val, arg_name}, state ->
         put_in(state, [:scope, arg_name], val)
       end)
       |> put_in([:service, :line], line)
       |> put_in([:service, :column], column)
       |> function.(), state}
    else
      _ ->
        raise "Error in Ln #{line}, Col #{column}: #{function_name}/#{length(args)} is not defined"
    end
  end

  defp take_value(%{value: value}), do: value

  defp take_value([%{value: value} | children]) do
    [value | Enum.map(children, &take_value/1)]
  end
end


# handle_function_call should handle not only list with nodes but with also just values (runtime generated) and also lambda should be valuable as function name
