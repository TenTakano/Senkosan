defmodule Senkosan.Consumer do
  @moduledoc false

  use Nostrum.Consumer

  alias Nostrum.Api
  alias Senkosan.Util
  alias Senkosan.VoiceState

  @default_text_channel Application.get_env(:senkosan, :default_text_channel)

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    if VoiceState.process_transition(msg) == :join do
      Util.apply_bot_usage(msg.user_id, fn ->
        Api.create_message(@default_text_channel, "おかえりなのじゃ！")
      end)
    end
  end

  def handle_event(_event) do
    :noop
  end
end
