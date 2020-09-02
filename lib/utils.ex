defmodule Senkosan.Utils do
  def apply_bot_usage(is_bot, func) do
    react_to_bot = Application.get_env(:senkosan, :react_to_bot)
    (is_bot and !react_to_bot) && :ok || func.()
  end
end
