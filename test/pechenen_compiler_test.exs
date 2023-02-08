defmodule PechenenCompilerTest do
  use ExUnit.Case
  doctest PechenenCompiler

  test "greets the world" do
    assert PechenenCompiler.hello() == :world
  end
end
