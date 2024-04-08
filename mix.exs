defmodule SummonerWatcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :summoner_watcher,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      # escript: [main_module: SummonerWatcher],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SummonerWatcher, []},
      extra_applications: [:tesla, hackney: :optional]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      {:tesla, "~> 1.4"},
      # optional, but recommended adapter
      {:hackney, "~> 1.17"},
      # optional, required by JSON middleware
      {:jason, "~> 1.2"}
    ]
  end
end
