# elixir-kiss

## Usage

```bash
# To update my exisiting project I did
# mix new . --app chat --sup
mix deps.get
# terminal 1 (sname is 'short name', --name is fully qualified name)
iex --sname alex@localhost -S mix
# terminal 2
iex --sname kate@localhost -S mix

# Then something like this should be possible
iex(alex@localhost)4> Chat.send_message(:kate@localhost, "hi")
:ok
# ...
iex(kate@localhost)2> hi
```
