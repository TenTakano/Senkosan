defmodule Senkosan.Ets.VoiceStateTest do
  use ExUnit.Case, async: true

  alias Senkosan.Ets.VoiceState

  setup do
    table = VoiceState.start_link()
    user_id = 123
    expected = %VoiceState{
      name: "someone",
      is_bot: false,
      channel_id: nil,
      is_greeted: false
    }
    {:ok, table: table, user_id: user_id, expected: expected}
  end

  test "insert/2 inserts given attrs and returns the process sccess or not", ctx do
    %{table: table, user_id: user_id, expected: expected} = ctx
    assert :ets.first(table) == :"$end_of_table"

    assert VoiceState.insert(user_id, expected) == true
    assert :ets.lookup_element(table, user_id, 2) == expected
  end

  test "fetch/1 returns attributes of user whose id matches with given user_id", ctx do
    %{table: table, user_id: user_id, expected: expected} = ctx
    :ets.insert(table, {user_id, expected})

    assert VoiceState.fetch(user_id) == expected
  end

  test "update/2 updates existing user state with given attributes and return the process success or not", ctx do
    %{table: table, user_id: user_id, expected: user_state} = ctx
    :ets.insert(table, {user_id, user_state})

    expected = %VoiceState{
      name: "updated_user",
      is_bot: false,
      channel_id: nil,
      is_greeted: false
    }
    assert VoiceState.update(user_id, expected) == true
    assert :ets.lookup_element(table, user_id, 2) == expected
  end
end
