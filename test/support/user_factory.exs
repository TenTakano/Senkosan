defmodule Senkosan.UserFactory do
  use ExMachina

  alias Nostrum.Struct

  def guild_member_factory do
    %Struct.Guild.Member{
      deaf: false,
      joined_at: "2020-05-25T08:58:02.860000+00:00",
      mute: false,
      nick: nil,
      roles: [123],
      user: build(:user)
    }
  end

  def user_factory() do
    %Struct.User{
      avatar: "abc",
      bot: nil,
      discriminator: "123",
      email: nil,
      id: sequence(:user_id, & &1),
      mfa_enabled: nil,
      public_flags: build(:user_flag),
      username: sequence("someone-"),
      verified: nil
    }
  end

  def user_flag_factory() do
    %Struct.User.Flags{
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
    }
  end
end
