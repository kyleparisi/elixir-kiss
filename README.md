# elixir-kiss

## Usage

```bash
mix deps.get
# terminal 1
iex --name a@127.0.0.1 -S mix
# terminal 2
iex --name b@127.0.0.1 -S mix

# either terminal
MyApp.ExampleUsage.start_worker("abc")
MyApp.ExampleUsage.get_worker("abc")
MyApp.ExampleUsage.get_foos()
```
