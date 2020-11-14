defmodule HomeBotTest do
  use ExUnit.Case
  doctest HomeBot

  test "greets the world" do
    assert HomeBot.hello() == :world
  end
end
