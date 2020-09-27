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
      channel_id = 123
      message = MessageFactory.build(:voice_state, %{channel_id: channel_id, user_id: user_id})

      {:ok, user_id: user_id, user_base: user_base, default_voice_channel: channel_id, message: message}
    end

    test "returns :mic_op if prev channel id equals new channel id", ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message_base
      } = ctx

      Enum.each([
        nil,
        default_voice_channel,
        456
      ], fn channel_id ->
        user = Map.put(user_base, :channel_id, channel_id)
        :ets.update_element(@table_name, user_id, {2, user})

        message = Map.put(message_base, :channel_id, channel_id)
        assert VoiceState.get_op(message) == :mic_op
        assert :ets.lookup_element(@table_name, user_id, 2) == user
      end)
    end

    test "returns :join if the user joins in more than 15 mins after the user left", ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message
      } = ctx

      left_at = DateTime.utc_now() |> DateTime.add(-(15 * 60 + 1))
      user = Map.put(user_base, :left_at, left_at)
      :ets.update_element(@table_name, user_id, {2, user})

      assert VoiceState.get_op(message) == :join

      user_channel_id = :ets.lookup_element(@table_name, user_id, 2) |> Map.get(:channel_id)
      assert user_channel_id == default_voice_channel
    end

    test "returns :reload if the user joins again in less than 15 mins", ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message
      } = ctx

      left_at = DateTime.utc_now() |> DateTime.add(-(15 * 60 - 1))
      user = Map.put(user_base, :left_at, left_at)
      :ets.update_element(@table_name, user_id, {2, user})

      assert VoiceState.get_op(message) == :reload

      user_channel_id = :ets.lookup_element(@table_name, user_id, 2) |> Map.get(:channel_id)
      assert user_channel_id == default_voice_channel
    end

    test "returns :other_transition for the cases that the destination is not the default voice channel", ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message_base
      } = ctx

      Enum.each([
        {default_voice_channel, nil},
        {default_voice_channel, 321},
        {234, nil},
        {nil, 234},
        {234, 245}
      ], fn {orig, dest} ->
        message = Map.put(message_base, :channel_id, dest)
        user = Map.put(user_base, :channel_id, orig)
        :ets.update_element(@table_name, user_id, {2, user})
        
        assert VoiceState.get_op(message) == :other_transition

        user_channel_id = :ets.lookup_element(@table_name, user_id, 2) |> Map.get(:channel_id)
        assert user_channel_id == dest
      end)
    end
  end
end
