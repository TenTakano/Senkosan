defmodule Senkosan.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Senkosan.SessionObserver
  alias Senkosan.Utils

  @default_text_channel Application.get_env(:senkosan, :default_text_channel)

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:VOICE_STATE_UPDATE, msg, _}) do
    IO.inspect msg
    if SessionObserver.update(msg) == :join do
      Utils.apply_bot_usage(
        Map.get(msg.member.user, :bot, false),
        fn -> Api.create_message(@default_text_channel, "おかえりなのじゃ！") end
      )
    end
  end

  def handle_event(_event) do
    :noop
  end
end
