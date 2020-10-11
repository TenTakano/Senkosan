defmodule Senkosan do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Senkosan.VoiceState.init()

    children = [
      {Senkosan.Consumer, []}
    ]

    opts = [strategy: :one_for_one, name: Senkosan.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
