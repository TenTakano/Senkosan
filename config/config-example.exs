use Mix.Config

config :logger,
  level: :warn

config :nostrum,
  # bot token
  token: "bot-token",
  num_shards: 2

config :senkosan,
  # voice channel id which the bot observes
  default_voice_channel: 12345,
  # text channel id which the bot posts messages
  default_text_channel: 12345
