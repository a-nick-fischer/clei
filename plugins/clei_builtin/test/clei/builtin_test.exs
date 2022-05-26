defmodule Clei.BuiltinTest do
  use ExUnit.Case
  doctest Clei.Builtin

  test "greets the world" do
    assert Clei.Builtin.hello() == :world
  end
end
