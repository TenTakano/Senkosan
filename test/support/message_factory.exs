defmodule Senkosan.MessageFactory do
  use ExMachina

  def voice_state_factory() do
    user_id = sequence(:voice_state_user_id, &(&1))

    %{
      channel_id: nil,
      deaf: false,
      guild_id: 123,
      member: %{
        deaf: false,
        hoisted_role: nil,
        joined_at: "2017-06-15T14:09:31.981000+00:00",
        mute: false,
        nick: "some_nickname",
        premium_since: nil,
        roles: [123],
        user: %{
          avatar: "3cd99452",
          discriminator: "1234",
          id: user_id,
          username: "someone"
        }
      },
      mute: false,
      self_deaf: false,
      self_mute: false,
      self_video: false,
      session_id: "7be873ea54",
      suppress: false,
      user_id: user_id
    }
  end  
end
