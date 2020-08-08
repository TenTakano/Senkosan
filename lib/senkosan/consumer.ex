defmodule Senkosan.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Senkosan.SessionObserver

  @default_text_channel Application.get_env(:senkosan, :default_text_channel)

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    if SessionObserver.update(msg) == :join do
      Api.create_message(@default_text_channel, "おかえりなのじゃ！")
    end
  end

  def handle_event(_event) do
    :noop
  end
end
