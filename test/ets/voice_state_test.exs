defmodule Senkosan.Ets.VoiceStateTest do
  use ExUnit.Case, async: true

  alias Senkosan.Ets.VoiceState
  alias Senkosan.UserFactory

  @table_name :senkosan_voice_state

  describe "init/1 " do
    test "creates voice_state table on ETS and inserts the formatted user attributes" do
      guild_id = 123
      users = UserFactory.build_pair(:guild_member)
      :meck.expect(Nostrum.Api, :list_guild_members!, fn (^guild_id, limit: 1000) -> users end)

      expected =
        users
        |> Enum.map(fn %{user: user} ->
          {user.id, %VoiceState{name: user.username, is_bot: user.bot}}
        end)
        |> Enum.sort_by(&elem(&1, 0))

      assert VoiceState.init(guild_id) == :ok
      assert List.flatten(:ets.match(@table_name, :"$1")) == expected
    end
  end
end
