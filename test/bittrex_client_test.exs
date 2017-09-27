defmodule BittrexClientTest do
  use ExUnit.Case
  doctest BittrexClient

  test "greets the world" do
    assert BittrexClient.hello() == :world
  end
end
