defmodule Clei.CoreTest do
  use ExUnit.Case
  doctest Clei.Core

  test "greets the world" do
    assert Clei.Core.hello() == :world
  end
end
