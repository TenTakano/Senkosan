defmodule Senkosan.Application do
  use Application

  def start(_type, _args) do
    children =
      [
        {Senkosan.Consumer, []},
        {Senkosan.SessionObserver, []}
      ]

    opts = [strategy: :one_for_one, name: Senkosan.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
