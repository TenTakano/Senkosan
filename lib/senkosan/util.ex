defmodule Senkosan.Util do
  @moduledoc false

  alias Senkosan.VoiceState

  @spec apply_bot_usage(integer, function) :: any
  def apply_bot_usage(user_id, f) do
    react_to_bot = Application.get_env(:senkosan, :react_to_bot)

    case {VoiceState.bot_user?(user_id), react_to_bot} do
      {{:ok, false}, _} ->
        f.()

      {{:ok, true}, true} ->
        f.()

      _ ->
        :ok
    end
  end
end
