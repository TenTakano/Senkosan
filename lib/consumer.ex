defmodule Senkosan.Consumer do
  @moduledoc false

  use Nostrum.Consumer

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    Senkosan.VoiceState.parse(msg)
  end

  def handle_event(_event) do
    :noop
  end
end
