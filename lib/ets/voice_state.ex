defmodule Senkosan.Ets.VoiceState do
  use Agent

  @type t :: __MODULE__.t

  @enforce_keys [:name, :is_bot]
  defstruct [:name, :is_bot, :channel_id, is_greeted: false]

  def start_link() do
    table = :ets.new(:voice_state, [:ordered_set, :protected])
    Agent.start_link(fn -> table end, name: __MODULE__)
  end

  @spec insert(integer, t) :: boolean
  def insert(user_id, attrs) do
    Agent.get(__MODULE__, &(&1))
    |> :ets.insert_new({user_id, attrs})
  end

  @spec fetch(integer) :: t
  def fetch(user_id) do
    Agent.get(__MODULE__, &(&1))
    |> :ets.lookup_element(user_id, 2)
  end

  @spec update(integer, t) :: boolean
  def update(user_id, attrs) do
    Agent.get(__MODULE__, &(&1))
    |> :ets.update_element(user_id, {2, attrs})
  end
end
