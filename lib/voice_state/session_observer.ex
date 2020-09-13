defmodule Senkosan.VoiceState.Observer do
  @moduledoc false

  use Agent

  alias Nostrum.Api

  def start_link(state) do
    Agent.start_link(fn -> init(state) end, name: __MODULE__)
  end

  def init(_) do
    %{id: guild_id} = hd(Api.get_current_user_guilds!())

    guild_id
    |> Api.list_guild_members!(limit: 1000)
    |> Enum.into(%{}, &format_member_list/1)
  end

  defp format_member_list(%{user: %{id: user_id, bot: is_bot}}) do
    state = %{
      channel_id: nil,
      is_bot: is_bot
    }

    {user_id, state}
  end

  def update(channel_user) do
    state = Agent.get_and_update(__MODULE__, &{&1, update_state(channel_user, &1)})
    process_state_transition(channel_user, state)
  end

  defp process_state_transition({new_channel_id, user_id}, members) do
    default_voice_channel = Application.get_env(:senkosan, :default_voice_channel)
    %{channel_id: prev_channel_id} = Map.get(members, user_id)

    case {prev_channel_id, new_channel_id} do
      {nil, ^default_voice_channel} ->
        :join

      {channel_id, nil} when is_number(channel_id) ->
        :left

      _ ->
        :other
    end
  end

  defp update_state({new_channel_id, user_id}, members) do
    user_id = user_id

    new_user_state =
      Map.get(members, user_id)
      |> Map.put(:channel_id, new_channel_id)

    Map.put(members, user_id, new_user_state)
  end
end
