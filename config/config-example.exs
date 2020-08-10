use Mix.Config

config :logger,
  level: :warn

config :nostrum,
  token: "bot-token", # put token here
  num_shards: 2

config :senkosan,
  default_voice_channel: 12345, # put voice channel id which the bot observes
  default_text_channel: 12345,  # put text channel id which the bot posts messages
