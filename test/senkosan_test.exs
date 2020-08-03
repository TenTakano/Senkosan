defmodule SenkosanTest do
  use ExUnit.Case
  doctest Senkosan

  test "greets the world" do
    assert Senkosan.hello() == :world
  end
end
