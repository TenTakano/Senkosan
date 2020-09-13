defmodule Senkosan.VoiceState.ObserverTest do
  use ExUnit.Case, async: true

  alias Nostrum.Api
  alias Senkosan.VoiceState.Observer
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

      assert Observer.init([]) == expected
      assert_received {:guild_id, @dummy_guild_id}
    end
  end

  describe "update/1" do
    test "returns transition type for user transition" do
      default_vc = Application.get_env(:senkosan, :default_voice_channel)
      user_id = 12345

      {:ok, observer} = Agent.start_link(fn -> %{} end, name: Observer)

      for(
        {new_channel_id, channel_id, expected} <- [
          {default_vc, nil, :join},
          {nil, default_vc, :left},
          {default_vc, 123, :other},
          {123, default_vc, :other},
          {default_vc, default_vc, :other},
          {123, 123, :other},
          {123, 456, :other},
          {nil, nil, :other}
        ],
        is_bot <- [true, false]
      ) do
        users = %{user_id => %{channel_id: channel_id, id_bot: is_bot}}
        Agent.update(observer, fn _ -> users end)

        msg = {new_channel_id, user_id}
        assert Observer.update(msg) == expected

        expected_new_users = update_in(users, [user_id, :channel_id], fn _ -> new_channel_id end)
        assert Agent.get(observer, & &1) == expected_new_users
      end
    end
  end
end
