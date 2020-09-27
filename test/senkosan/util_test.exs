defmodule Senkosan.UtilTest do
  use ExUnit.Case, async: true

  alias Senkosan.Util
  alias Senkosan.VoiceState

  @voice_state_table_name :senkosan_voice_state

  describe "apply_bot_usage/2 " do
    setup do
      :ets.new(@voice_state_table_name, [:ordered_set, :protected, :named_table])
      f = fn -> :do_something end

      on_exit(fn -> Application.delete_env(:senkosan, :react_to_bot) end)

      {:ok, func: f}
    end

    test "always executes the given function if the user is not a bot", %{func: f} do
      user_id = 1

      user_attrs = %VoiceState{
        name: "someone",
        is_bot: false
      }

      :ets.insert(@voice_state_table_name, {user_id, user_attrs})

      Enum.each([true, false], fn react_to_bot ->
        Application.put_env(:senkosan, :react_to_bot, react_to_bot)
        assert Util.apply_bot_usage(user_id, f) == :do_something
      end)
    end

    test "executes the given function even if the user is a bot when react_to_bot is true", %{
      func: f
    } do
      user_id = 1

      user_attrs = %VoiceState{
        name: "someone",
        is_bot: true
      }

      :ets.insert(@voice_state_table_name, {user_id, user_attrs})

      Enum.each(
        [
          {true, :do_something},
          {false, :ok}
        ],
        fn {react_to_bot, expected} ->
          Application.put_env(:senkosan, :react_to_bot, react_to_bot)
          assert Util.apply_bot_usage(user_id, f) == expected
        end
      )
    end
  end
end
