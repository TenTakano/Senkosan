defmodule Senkosan.VoiceState do
  @moduledoc false

  use Agent

  @type t :: __MODULE__.t()

  @enforce_keys [:name, :is_bot]
  defstruct [:name, :is_bot, :channel_id, left_at: ~U[2000-01-01 00:00:00Z]]

  @table_name :senkosan_voice_state
  @ignore_seconds 15 * 60

  @doc """
  Creates a table to contain the voice states and insertes user states.
  Each user state is fetched by Discord guild member list API
  """
  @spec init(integer) :: :ok
  def init(guild_id) do
    :ets.new(@table_name, [:ordered_set, :public, :named_table])

    guild_id
    |> Nostrum.Api.list_guild_members!(limit: 1000)
    |> Enum.each(fn %{user: user} ->
      attrs = %__MODULE__{
        name: user.username,
        is_bot: if(user.bot, do: user.bot, else: false)
      }

      :ets.insert(@table_name, {user.id, attrs})
    end)

    :ok
  end

  @doc """
  Process state transitions and updates channel_id the user joins to.
  """
  @spec process_transition(map) :: atom
  def process_transition(%{channel_id: new_channel_id, user_id: user_id} = _) do
    default_voice_channel = Application.get_env(:senkosan, :default_voice_channel)
    user = get_user(user_id)

    trig_time =
      DateTime.utc_now()
      |> DateTime.add(-@ignore_seconds)

    case {user.channel_id, new_channel_id, DateTime.compare(user.left_at, trig_time)} do
      {prev, new, _} when prev == new ->
        :mic_op

      {_, ^default_voice_channel, :lt} ->
        new_user_attr = Map.put(user, :channel_id, new_channel_id)
        :ets.update_element(@table_name, user_id, {2, new_user_attr})
        :join

      {_, ^default_voice_channel, _} ->
        new_user_attr = Map.put(user, :channel_id, new_channel_id)
        :ets.update_element(@table_name, user_id, {2, new_user_attr})
        :reload

      _ ->
        new_user_attr =
          Map.merge(user, %{channel_id: new_channel_id, left_at: DateTime.utc_now()})

        :ets.update_element(@table_name, user_id, {2, new_user_attr})
        :other_transition
    end
  end

  @doc """
  Returns user attributes from ETS table.
  In case the user doesn't exist, create it by fetching with discord API
  """
  def get_user(user_id) do
    :ets.lookup_element(@table_name, user_id, 2)
  end

  @doc """
  Returns if the user is bot or not

  If the user doesn't exist, :error is returned
  """
  @spec bot_user?(integer) :: {:ok, boolean} | :error
  def bot_user?(user_id) do
    case :ets.lookup(@table_name, user_id) do
      [] ->
        :error

      [{_, %{is_bot: is_bot}}] ->
        {:ok, is_bot}
    end
  end
end
