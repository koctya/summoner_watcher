import Config

#   api_key: System.get_env("RIOT_API_KEY", "ddd")
config :summoner_watcher,
  api_key: System.get_env("RIOT_API_KEY")
