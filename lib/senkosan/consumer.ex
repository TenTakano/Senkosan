defmodule Senkosan.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  @default_voice_channel Application.get_env(:senkosan, :default_voice_channel)
  @default_text_channel Application.get_env(:senkosan, :default_text_channel)

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    if msg.channel_id != nil and msg.channel_id == @default_voice_channel do
      Api.create_message(@default_text_channel, "おかえりなのじゃ！")
    end
  end

  def handle_event(_event) do
    :noop
  end
end
