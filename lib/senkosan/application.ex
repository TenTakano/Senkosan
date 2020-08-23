defmodule Senkosan.Application do
  use Application

  def start(_type, _args) do
    children =
      if Mix.env() != :test do
        [
          {Senkosan.Consumer, []},
          {Senkosan.SessionObserver, []}
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: Senkosan.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
