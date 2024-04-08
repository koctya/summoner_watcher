defmodule SummonerWatcher do
  use Application
  @moduledoc """
  Documentation for `SummonerWatcher`.
  """
  require Tesla
  # import OptionParser

  def start(_type, _expoargs)do
    IO.puts"SummonerWatcher starting"

    children = [
    ]

    # args
    # |> OptionParser.parse
    # |> SummonerWatcher.process(strict: [name: :string])
    uname = IO.gets("\nusername: ")
    |> String.trim
    |> String.downcase
    |> dbg()

    reg = IO.gets("\nregion: ")
    |> String.trim
    |> String.upcase
    |> dbg()

    IO.inspect(SummonerWatcher.call(uname, reg))

    opts = [strategy: :one_for_one, name: SummonerWatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # def process(parsed_args, opts \\ []) do
  #   dbg(parsed_args)
  #   case parsed_args do
  #     { [ help: true ], _, _ } -> IO.puts "usage: issues <user> <region> "
  #     { _, [ user, reg ], _ } -> { user, reg }
  #     _ -> IO.puts "usage: --name <user> -- region <region> "
  #   end
  # end

  def call(sname \\ "Kenvi", reg \\ "NA") do
    participants = []
    url = Application.get_env(:summoner_watcher, :url)
    sreg = SummonerWatcher.summ_region(reg)
    mrte = SummonerWatcher.match_route(reg)
    cl = SummonerWatcher.client("https://#{sreg}.#{url}")
    clm = SummonerWatcher.client("https://#{mrte}.#{url}")
    summ = SummonerWatcher.get_summoner(cl, sname)
    puuid = summ["puuid"]
    matches = SummonerWatcher.get_matches(clm, puuid)
    participants = Enum.map(matches, fn(m) ->
      get_participants(clm, m, participants)
    end)
    parts = List.flatten(participants)
    summoners = Enum.map(parts, fn(p) ->
      {get_summoner_name(cl, p), p}
    end) |> Map.new()
    stime = DateTime.to_unix(DateTime.utc_now())
    etime = stime + 60 * 60  # run for 1 hour
    SummonerWatcher.monitor_matches(clm, summoners, etime)
    dbg(summoners)
    Map.keys(summoners)
  end

  def monitor_matches(clm, summoners, etime) do
    stime = DateTime.to_unix(DateTime.utc_now())
    Enum.map(summoners,  fn{name, p} ->
      Process.sleep(500)  # avoid rate limit.
        matches =  SummonerWatcher.get_matches(clm, p, stime)
        unless Enum.empty?(matches) do
          Enum.each(matches, fn(m) ->
            IO.puts("Summoner #{name} completed match #{m}")
          end)
        end
        dbg("Name: #{name} - Matches: #{matches}")
      # end
    end)
    dbg("time remaining: #{etime - stime}")
    Process.sleep(60_000)
    if stime < etime do
      monitor_matches(clm, summoners, etime)
    end
    :ok
  end

  def get_summoner(client, name \\ "Kenvi") do
    endpoint = Application.get_env(:summoner_watcher, :summoner)
    with  {:ok, result} = Tesla.get(client, endpoint <> name) do
      result.body
    end
  end

  def get_summoner_name(client, part) do
    endpoint = Application.get_env(:summoner_watcher, :summoner_by_puuid)
    # |> dbg()
    {:ok, result} = Tesla.get(client, endpoint <> part)
    result.body["name"]
  end

  def get_matches(client, puuid, stime \\ nil) do
    endpoint = Application.get_env(:summoner_watcher, :match_url)
    {:ok, result} = if stime != nil do
      endpoint = "#{endpoint}#{puuid}/ids?startTime=#{stime}"
      Tesla.get(client, endpoint)
    else
      endpoint = "#{endpoint}#{puuid}/ids?count=5"
      Tesla.get(client, endpoint)
    end
    result.body
  end

  def get_participants(client, match, part) do
    endpoint = Application.get_env(:summoner_watcher, :participants_url)
    {:ok, result} = Tesla.get(client, endpoint <> match )
    part ++ result.body["metadata"]["participants"]
  end

  def summ_region(reg) do
    case(reg) do
      "BR"    -> "br1"
      "EUNE"  -> "eun1"
      "EUW"   -> "euw1"
      "JP"    -> "jp1"
      "KR"    -> "kr"
      "LAN"   -> "la1"
      "LAS"   -> "la2"
      "NA"    -> "na1"
      "OCE"   -> "oc1"
      "TR"    -> "tr1"
      "RU"    -> "ru"
      _       -> "unk"
    end
  end

  def match_route(reg) do
    case(reg) do
      "BR"    -> "americas"
      "LAN"   -> "americas"
      "LAS"   -> "americas"
      "NA"    -> "americas"
      "JP"    -> "asia"
      "KR"    -> "asia"
      "ASIA"  -> "asia"
      "EUNE"  -> "europe"
      "EUW"   -> "europe"
      "RU"    -> "europe"
      "TR"    -> "europe"
      "OCE"   -> "sea"
      _       -> "unk"
    end
  end
#   client = GitHub.client(user_token)
# client |> GitHub.user_repos("teamon")
# client |> GitHub.get("/me")

  # build dynamic client based on runtime arguments
  def client(url) do
    middleware = [
      {Tesla.Middleware.BaseUrl, url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"X-Riot-Token", Application.get_env(:summoner_watcher, :api_key)}]}
    ]

    Tesla.client(middleware)
  end
end
