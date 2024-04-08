# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :tesla, adapter: {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

config :summoner_watcher,
  region: "AMERICAS",
  champions: "https://ddragon.leagueoflegends.com/cdn/14.7.1/data/en_US/champion.json",
  url: "api.riotgames.com",
  base_url: "https://developer.riotgames.com/apis#summoner-v4/GET_getBySummonerName",
  summoner: "/lol/summoner/v4/summoners/by-name/",
  summoner_by_puuid: "/lol/summoner/v4/summoners/by-puuid/", #{encryptedPUUID}
  match_url: "/lol/match/v5/matches/by-puuid/",
  participants_url: "/lol/match/v5/matches/" # {matchId}
