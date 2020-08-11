defmodule Senkosan.SessionObserverTest do
  use ExUnit.Case

  alias Nostrum.Api
  alias Senkosan.SessionObserver
  alias Nostrum.Struct

  @dummy_guild_id 123
  @dummy_guilds [
    %Struct.Guild{
      afk_channel_id: nil,
      afk_timeout: nil,
      application_id: nil,
      channels: nil,
      default_message_notifications: nil,
      embed_channel_id: nil,
      embed_enabled: nil,
      emojis: nil,
      explicit_content_filter: nil,
      features: [],
      icon: "abcdef",
      id: @dummy_guild_id,
      joined_at: nil,
      large: nil,
      member_count: nil,
      members: nil,
      mfa_level: nil,
      name: "somename",
      owner_id: nil,
      region: nil,
      roles: nil,
      splash: nil,
      system_channel_id: nil,
      unavailable: nil,
      verification_level: nil,
      voice_states: nil,
      widget_channel_id: nil,
      widget_enabled: nil
    }
  ]
  @dummy_users [
    %Struct.Guild.Member{
      deaf: false,
      joined_at: "2020-05-25T08:58:02.860000+00:00",
      mute: false,
      nick: nil,
      roles: [123],
      user: %Struct.User{
        avatar: "abc",
        bot: nil,
        discriminator: "123",
        email: nil,
        id: 123_456,
        mfa_enabled: nil,
        public_flags: %Struct.User.Flags{
          bug_hunter_level_1: false,
          bug_hunter_level_2: false,
          early_supporter: false,
          hypesquad_balance: false,
          hypesquad_bravery: false,
          hypesquad_brilliance: false,
          hypesquad_events: false,
          partner: false,
          staff: false,
          system: false,
          team_user: false,
          verified_bot: false,
          verified_developer: false
        },
        username: "someone",
        verified: nil
      }
    },
    %Struct.Guild.Member{
      deaf: false,
      joined_at: "2020-08-05T15:38:47.503000+00:00",
      mute: false,
      nick: nil,
      roles: [123],
      user: %Struct.User{
        avatar: "abcdef",
        bot: true,
        discriminator: "321",
        email: nil,
        id: 654_321,
        mfa_enabled: nil,
        public_flags: %Struct.User.Flags{
          bug_hunter_level_1: false,
          bug_hunter_level_2: false,
          early_supporter: false,
          hypesquad_balance: false,
          hypesquad_bravery: false,
          hypesquad_brilliance: false,
          hypesquad_events: false,
          partner: false,
          staff: false,
          system: false,
          team_user: false,
          verified_bot: false,
          verified_developer: false
        },
        username: "botuser",
        verified: nil
      }
    }
  ]

  setup_all do
    :meck.expect(Api, :get_current_user_guilds!, fn -> @dummy_guilds end)
  end

  describe "init/1" do
    test "generates member list" do
      :meck.expect(Api, :list_guild_members!, fn guild_id, _ ->
        send(self(), {:guild_id, guild_id})
        @dummy_users
      end)

      expected =
        @dummy_users
        |> Enum.map(&{&1.user.id, %{channel_id: nil, is_bot: &1.user.bot}})
        |> Map.new()

      assert {:ok, members} = SessionObserver.init([])
      assert members == expected
      assert_received {:guild_id, @dummy_guild_id}
    end
  end

  describe "When handle_call/1 gets :update, handle_call/1" do
    test "returns :join if the user move to the default voice channel" do
      user_id = 12345
      channel_id = 123_456_789
      :meck.expect(Application, :get_env, fn :senkosan, :default_voice_channel -> channel_id end)

      Enum.each(
        [
          {nil, channel_id, :join},
          {channel_id, nil, :left},
          {987_654_321, channel_id, :other},
          {channel_id, 987_654_321, :other},
          {channel_id, channel_id, :other}
        ],
        fn {prev_channel, new_channel, transition} ->
          prev_state = %{user_id => %{channel_id: prev_channel, is_bot: false}}
          msg = %{channel_id: new_channel, member: %{user: %{id: user_id}}}

          expected_state = %{user_id => %{channel_id: new_channel, is_bot: false}}

          assert {:reply, ^transition, new_state} =
                   SessionObserver.handle_call({:update, msg}, [], prev_state)

          assert new_state == expected_state
        end
      )
    end
  end
end
