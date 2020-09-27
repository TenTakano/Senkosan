defmodule Senkosan.Ets.VoiceStateTest do
  use ExUnit.Case, async: true

  alias Senkosan.{UserFactory, MessageFactory}
  alias Senkosan.Ets.VoiceState

  @table_name :senkosan_voice_state

  describe "init/1 " do
    test "creates voice_state table on ETS and inserts the formatted user attributes" do
      guild_id = 123
      users = UserFactory.build_pair(:guild_member)
      :meck.expect(Nostrum.Api, :list_guild_members!, fn (^guild_id, limit: 1000) -> users end)

      expected =
        users
        |> Enum.map(fn %{user: user} ->
          {user.id, %VoiceState{name: user.username, is_bot: user.bot}}
        end)
        |> Enum.sort_by(&elem(&1, 0))

      assert VoiceState.init(guild_id) == :ok
      assert List.flatten(:ets.match(@table_name, :"$1")) == expected
    end
  end

  describe "get_op/1 " do
    setup do
      :ets.new(@table_name, [:ordered_set, :protected, :named_table])

      user_id = 1
      user_base = %VoiceState{
        name: "someone",
        is_bot: false
      }
      :ets.insert(@table_name, {user_id, user_base})

      {:ok, user_id: user_id, user_base: user_base, default_voice_channel: 123}
    end

    test "returns :mic_op if prev channel id equals new channel id", ctx do
      %{user_id: user_id, user_base: user_base, default_voice_channel: default_voice_channel} = ctx

      Enum.each([
        nil,
        default_voice_channel,
        456
      ], fn channel_id ->
        user = Map.put(user_base, :channel_id, channel_id)
        :ets.update_element(@table_name, user_id, {2, user})

        message = MessageFactory.build(:voice_state, %{channel_id: channel_id, user_id: user_id})
        assert VoiceState.get_op(message) == :mic_op
        assert :ets.lookup_element(@table_name, user_id, 2) == user
      end)
    end
  end
end
