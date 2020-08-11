defmodule Senkosan.UtilsTest do
  use ExUnit.Case, async: true

  import Senkosan.Utils

  describe "apply_bot_usage/1" do
    setup do
      f = fn -> :do_something end

      on_exit(fn -> Application.delete_env(:senkosan, :react_to_bot) end)

      {:ok, func: f}
    end

    test "executes the given function if @react_to_bot is true", %{func: f} do
      Application.put_env(:senkosan, :react_to_bot, true)

      assert apply_bot_usage(true, f) == :do_something
      assert apply_bot_usage(false, f) == :do_something
    end

    test "executes the given function only with is_bot as false if @react_to_bot is false", %{
      func: f
    } do
      Application.put_env(:senkosan, :react_to_bot, false)

      assert apply_bot_usage(true, f) == :ok
      assert apply_bot_usage(false, f) == :do_something
    end
  end
end
