defmodule Senkosan.VoiceStateTest do
  use ExUnit.Case, async: true

  alias Nostrum.Api
  alias Senkosan.{GuildFactory, MessageFactory, UserFactory}
  alias Senkosan.VoiceState

  @table_name :senkosan_voice_state

  describe "init/1 " do
    test "creates voice_state table on ETS" do
      assert VoiceState.init() == :ok
      refute :ets.whereis(@table_name) == :undefined
    end
  end

  describe "process_transition/1 " do
    setup do
      :ets.new(@table_name, [:ordered_set, :protected, :named_table])

      user_id = 1

      user_base = %VoiceState{
        name: "someone",
        is_bot: false
      }

      :ets.insert(@table_name, {user_id, user_base})
      channel_id = Application.get_env(:senkosan, :default_voice_channel)
      message = MessageFactory.build(:voice_state, %{channel_id: channel_id, user_id: user_id})

      {:ok,
       user_id: user_id, user_base: user_base, default_voice_channel: channel_id, message: message}
    end

    test "returns :mic_op if prev channel id equals new channel id", ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message_base
      } = ctx

      Enum.each(
        [
          nil,
          default_voice_channel,
          456
        ],
        fn channel_id ->
          user = Map.put(user_base, :channel_id, channel_id)
          :ets.update_element(@table_name, user_id, {2, user})

          message = Map.put(message_base, :channel_id, channel_id)
          assert VoiceState.process_transition(message) == :mic_op
          assert :ets.lookup_element(@table_name, user_id, 2) == user
        end
      )
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

      assert VoiceState.process_transition(message) == :join

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

      assert VoiceState.process_transition(message) == :reload

      user_channel_id = :ets.lookup_element(@table_name, user_id, 2) |> Map.get(:channel_id)
      assert user_channel_id == default_voice_channel
    end

    test "returns :other_transition for the cases that the destination is not the default voice channel",
         ctx do
      %{
        user_id: user_id,
        user_base: user_base,
        default_voice_channel: default_voice_channel,
        message: message_base
      } = ctx

      Enum.each(
        [
          {default_voice_channel, nil},
          {default_voice_channel, 321},
          {234, nil},
          {nil, 234},
          {234, 245}
        ],
        fn {orig, dest} ->
          message = Map.put(message_base, :channel_id, dest)
          user = Map.put(user_base, :channel_id, orig)
          :ets.update_element(@table_name, user_id, {2, user})

          assert VoiceState.process_transition(message) == :other_transition

          user_channel_id = :ets.lookup_element(@table_name, user_id, 2) |> Map.get(:channel_id)
          assert user_channel_id == dest
        end
      )
    end
  end

  describe "get_user/1" do
    setup do
      :ets.new(@table_name, [:ordered_set, :protected, :named_table])
      :ok
    end

    test "returns user attributes in ETS table" do
      user_id = 1

      attrs = %VoiceState{
        name: "someone",
        is_bot: false
      }

      :ets.insert(@table_name, {user_id, attrs})

      assert VoiceState.get_user(user_id) == attrs
    end

    test "returns user attributes fetched by discord API in case ETS table doesn't have the user" do
      guild_member = UserFactory.build(:guild_member)
      user_id = guild_member.user.id

      expected = %VoiceState{
        name: guild_member.user.username,
        is_bot: guild_member.user.bot
      }

      guilds = [GuildFactory.build(:guild)]
      guild_id = Map.fetch!(hd(guilds), :id)
      :meck.expect(Api, :get_current_user_guilds!, fn -> guilds end)
      :meck.expect(Api, :get_guild_member!, fn ^guild_id, ^user_id -> guild_member end)

      VoiceState.get_user(user_id)
      assert VoiceState.get_user(user_id) == expected
      assert :ets.lookup_element(@table_name, user_id, 2) == expected
    end
  end

  describe "bot_user?/1 " do
    setup do
      :ets.new(@table_name, [:ordered_set, :protected, :named_table])
      :ok
    end

    test "returns if the user is bot or not" do
      Enum.each([true, false], fn is_bot ->
        user_id = 1

        user = %VoiceState{
          name: "someone",
          is_bot: is_bot
        }

        :ets.insert(@table_name, {user_id, user})

        assert VoiceState.bot_user?(user_id) == {:ok, is_bot}
      end)
    end

    test "returns :error if the user doesn't exist" do
      assert VoiceState.bot_user?(3) == :error
    end
  end
end
