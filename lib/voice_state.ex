defmodule Senkosan.VoiceState do
  alias Nostrum.Api
  alias Senkosan.SessionObserver
  alias Senkosan.Utils

  @default_text_channel Application.get_env(:senkosan, :default_text_channel)

  def parse(msg) do
    %{channel_id: channel_id, member: %{user: user}} = msg
    if SessionObserver.update({channel_id, user.id}) == :join do
      Utils.apply_bot_usage(
        Map.get(user, :bot, false),
        fn -> Api.create_message(@default_text_channel, "おかえりなのじゃ！") end
      )
    end    
  end
end
