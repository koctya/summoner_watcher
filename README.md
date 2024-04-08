# SummonerWatcher

Given a valid summoner_name and region will fetch all summoners this summoner has played with in the last 5 matches. This data is returned to the caller as a list of summoner names

### list of Summoner names to use in testing was found on [Leaderboard](https://www.op.gg/leaderboards/tier)

## Configuration

Add an environment var with the Riot Api Key; 

    ✗ export RIOT_API_KEY=RGAPI-012345678901234567890-1234567890-123456

## Running

Run application using mix, or iex;

    ✗ mix run 

    ✗ iex -S mix
