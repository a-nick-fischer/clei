defmodule CleiTest do
  use ExUnit.Case
  doctest Clei

  test "greets the world" do
    assert Clei.hello() == :world
  end
end
