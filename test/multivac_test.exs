defmodule MultivacTest do
  use ExUnit.Case
  doctest Multivac

  test "greets the world" do
    assert Multivac.hello() == :world
  end
end
