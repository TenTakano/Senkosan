defmodule SenkosanTest do
  use ExUnit.Case

  describe "get_guild_id/0" do
    setup do
      on_exit(&:meck.unload/0)
    end

    test "returns guild id which the bot belongs to" do
      # dummy_guild_id = 123_456_789
      # :meck.expect(Nostrum.Api, :get_current_user_guilds!, fn -> [%{id: dummy_guild_id}] end)

      # assert Senkosan.set_guild_id_to_env() == :ok
      # assert Application.get_env(:senkosan, :guild_id) == dummy_guild_id
    end
  end
end
