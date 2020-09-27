defmodule Senkosan.Consumer do
  @moduledoc false

  use Nostrum.Consumer

  alias Senkosan.Utils
  alias Senkosan.VoiceState

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    Utils.apply_bot_usage(msg.user_id, VoiceState.process_transition(msg))
  end

  def handle_event(_event) do
    :noop
  end
end
