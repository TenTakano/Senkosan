defmodule Senkosan.Ets.VoiceState do
  use Agent

  alias Nostrum.Struct.Message

  @type t :: __MODULE__.t

  @enforce_keys [:name, :is_bot]
  defstruct [:name, :is_bot, :channel_id, is_greeted: false]

  @table_name :senkosan_voice_state

  @doc """
  Creates a table to contain the voice states and insertes user states.
  Each user state is fetched by Discord guild member list API
  """
  @spec init(integer) :: :ok
  def init(guild_id) do
    :ets.new(@table_name, [:ordered_set, :protected, :named_table])

    guild_id
    |> Nostrum.Api.list_guild_members!(limit: 1000)
    |> Enum.each(fn %{user: user} ->
      attrs = %__MODULE__{
        name: user.username,
        is_bot: user.bot
      }
      :ets.insert(@table_name, {user.id, attrs})
    end)

    :ok
  end

  @spec get_op(map) :: atom
  def get_op(%{channel_id: new_channel_id, user_id: user_id} = _) do
    user = :ets.lookup_element(@table_name, user_id, 2)

    case {user, new_channel_id} do
      {%{channel_id: prev}, new} when prev == new ->
        :mic_op
      {%{channel_id: nil}, _} ->
        :join
      {_, nil} ->
        :left
    end
  end
end
