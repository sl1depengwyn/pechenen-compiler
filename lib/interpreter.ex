defmodule Interpreter do
  alias Parser.Node

  @spec interpret([Node.t()], [String.t() | integer()]) :: any()
  def interpret(ast, args) do
    {_value, state} =
      Enum.reduce(ast, {nil, initial_state()}, fn node, {_value, acc} ->
        {value, state} = interpret_node(node, acc)
        IO.inspect(value, label: "value")
        {value, state}
      end)

    {:ok,
     if prog = state.service[:prog] do
       with {func_args, function} <- prog,
            {:number_of_args, true} <- {:number_of_args, length(args) == length(func_args)} do
         args
         |> Enum.zip(func_args)
         |> Enum.reduce(state, fn {val, arg_name}, state ->
           put_in(state, [:scope, arg_name], val)
         end)
         |> put_in([:service, :line], -1)
         |> put_in([:service, :column], -1)
         |> function.()
       else
         _ ->
           raise "prog definition error"
       end
     end}
  end

  def initial_state do
    %{
      scope:
        arithmetic_functions()
        |> Map.merge(comparisons_functions())
        |> Map.merge(io_functions())
        |> Map.merge(default_atoms()),
      service: %{line: 0, column: 0, returned?: false}
    }
  end

  def io_functions do
    [
      print: &IO.inspect/1
    ]
    |> Map.new(fn {name, func} ->
      {name,
       {[:a],
        fn
          %{scope: %{a: a}} ->
            func.(a)
        end}}
    end)
  end

  def comparisons_functions do
    [
      equal: &Kernel.==/2,
      nonequal: &Kernel.!=/2,
      less: &Kernel.</2,
      lesseq: &Kernel.<=/2,
      greater: &Kernel.>/2,
      greatereq: &Kernel.>=/2
    ]
    |> Map.new(fn {name, func} ->
      {name,
       {[:a, :b],
        fn
          %{scope: %{a: a, b: b}}
          when (is_boolean(a) or is_number(a)) and (is_boolean(b) or is_number(b)) ->
            func.(a, b)

          %{service: %{line: line, column: column}, scope: %{a: a, b: b}} ->
            raise "Error in Ln #{line}, Col #{column}: Both #{name} arguments should be numbers or boolean, got #{a} and #{b}"
        end}}
    end)
  end

  def arithmetic_functions do
    [plus: &Kernel.+/2, minus: &Kernel.-/2, times: &Kernel.*/2, divide: &Kernel.//2]
    |> Map.new(fn {name, func} ->
      {name,
       {[:a, :b],
        fn
          %{scope: %{a: a, b: b}} when is_number(a) and is_number(b) ->
            func.(a, b)

          %{service: %{line: line, column: column}, scope: %{a: a, b: b}} ->
            raise "Error in Ln #{line}, Col #{column}: Both #{name} arguments should be numbers, got #{a} and #{b}"
        end}}
    end)
  end

  def default_atoms do
    %{true: true, false: false, null: nil}
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

  def interpret_node([[_ | _] = node | children], state, return_state?) do
    func_name = interpret_node(node, state, false)

    {value, state} =
      interpret_function_call(
        %{line: state.service.line, column: state.service.column, value: func_name},
        children,
        state
      )

    if return_state? do
      {value, state}
    else
      value
    end
  end

  def interpret_node(i, state, _return_state?) do
    IO.inspect(i, label: "134134234")
    raise "Error in Ln #{state.service.line}, Col #{state.service.column}: Illegal function name"
  end

  def interpret_function_call(%{value: :func}, [%{value: name}, args, body], state) do
    args = Enum.map(args, &take_value/1)

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
    args = Enum.map(args, &take_value/1)

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

  def interpret_function_call(%{value: :while} = value, [condition, body] = args, state) do
    condition = interpret_node(condition, state, false)

    unless is_boolean(condition) do
      raise "Error in Ln #{state.service.line}, Col #{state.service.column}: cond expects first argument to be boolean, got: #{condition}"
    end

    if !state.service[:broken?] and !state.service[:returned?] and condition do
      {_, state} = interpret_node(body, state)
      interpret_function_call(value, args, state)
    else
      {nil, state}
    end
  end

  def interpret_function_call(%{value: :break}, [], state) do
    {nil, put_in(state, [:service, :broken?], true)}
  end

  def interpret_function_call(%{value: :return}, [arg], state) do
    {interpret_node(arg, state, false), put_in(state, [:service, :returned?], true)}
  end

  def interpret_function_call(%{value: :eval}, [arg], state) when is_list(arg) do
    {interpret_node(arg, state, false), state}
  end

  def interpret_function_call(%{value: :eval}, [arg], state) do
    {take_value(arg), state}
  end

  def interpret_function_call(%{value: :prog}, [args, body], state) do
    args = Enum.map(args, &take_value/1)

    prog = fn state ->
      interpret_node(body, state)
    end

    {nil, put_in(state, [:service, :prog], {args, prog})}
  end

  def interpret_function_call(
        %{value: {func_args, function}, line: _line, column: _column},
        args,
        state
      ) do
    with {:number_of_args, true} <- {:number_of_args, length(args) == length(func_args)} do
      {args
       |> Enum.map(&interpret_node(&1, state, false))
       |> Enum.zip(func_args)
       |> Enum.reduce(state, fn {val, arg_name}, state ->
         put_in(state, [:scope, arg_name], val)
       end)
       |> function.(), state}
    else
      _ ->
        raise "Error in Ln #{state.service.line}, Col #{state.service.column}: lambda_function/#{length(args)} is not defined"
    end
  end

  def interpret_function_call(%{value: function_name, line: line, column: column}, args, state)
      when is_atom(function_name) do
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

  def interpret_function_call(i, _args, state) do
    IO.inspect(i, label: "fucnoitiknjrnf ")
    raise "Error in Ln #{state.service.line}, Col #{state.service.column}: Illegal function name"
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
      interpret_node(else_clause, state)
    end
  end

  defp take_value(%{value: value}), do: value

  defp take_value([%{value: value} | children]) do
    [value | Enum.map(children, &take_value/1)]
  end
end
