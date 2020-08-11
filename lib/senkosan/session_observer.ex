defmodule Senkosan.SessionObserver do
  use GenServer

  alias Nostrum.Api

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def update(msg) do
    GenServer.call(__MODULE__, {:update, msg})
  end

  @impl true
  def init(_) do
    %{id: guild_id} = hd(Api.get_current_user_guilds!())

    member_list =
      guild_id
      |> Api.list_guild_members!(limit: 1000)
      |> format_member_list()

    {:ok, member_list}
  end

  defp format_member_list(members) do
    Enum.reduce(members, %{}, fn %{user: user}, acc ->
      state = %{
        channel_id: nil,
        is_bot: user.bot
      }

      Map.put(acc, user.id, state)
    end)
  end

  @impl true
  def handle_call({:update, msg}, _client, state) do
    state_transition = process_state_transition(msg, state)
    new_state = update_state(msg, state)
    {:reply, state_transition, new_state}
  end

  defp process_state_transition(msg, members) do
    default_voice_channel = Application.get_env(:senkosan, :default_voice_channel)
    %{channel_id: prev_channel_id} = Map.get(members, msg.member.user.id)

    case {prev_channel_id, msg.channel_id} do
      {nil, ^default_voice_channel} ->
        :join

      {_, nil} ->
        :left

      _ ->
        :other
    end
  end

  defp update_state(msg, members) do
    user_id = msg.member.user.id

    new_user_state =
      Map.get(members, user_id)
      |> Map.put(:channel_id, msg.channel_id)

    Map.put(members, user_id, new_user_state)
  end
end
