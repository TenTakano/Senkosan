defmodule Senkosan do
  @moduledoc false

  use Application

  def start(_type, _args) do
    init_voice_state()

    children = [
      {Senkosan.Consumer, []}
    ]

    opts = [strategy: :one_for_one, name: Senkosan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init_voice_state() do
    Nostrum.Api.get_current_user_guilds!()
    |> hd()
    |> Map.fetch!(:id)
    |> Senkosan.VoiceState.init()
  end
end
