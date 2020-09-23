defmodule Senkosan.GuildFactory do
  use ExMachina

  def guild_factory() do
    %Nostrum.Struct.Guild{
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
  end
end
