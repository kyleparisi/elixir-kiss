# elixir-kiss

## Usage

Reference: [https://blog.carbonfive.com/2018/01/30/comparing-dynamic-supervision-strategies-in-elixir-1-5-and-1-6/](https://blog.carbonfive.com/2018/01/30/comparing-dynamic-supervision-strategies-in-elixir-1-5-and-1-6/)

```bash
mix deps.get
iex --name a@127.0.0.1 -S mix

# Start Player Supervisor
{:ok, _} = PlayerDynamicSupervisor.start_link([])
# Start Game
game_id = 1
{:ok, pid} = Game.start_link(game_id)
# Add player to game
Game.add_player(pid, "Player One")

PlayerDynamicSupervisor.count_children
# %{active: 1, specs: 1, supervisors: 0, workers: 1}
```
