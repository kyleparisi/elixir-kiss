# elixir-kiss

## Usage

```bash
mix deps.get
# terminal 1
iex --name a@127.0.0.1 -S mix
# terminal 2
iex --name b@127.0.0.1 -S mix

# either terminal, Node.list.  example:
iex(b@127.0.0.1)1> Node.list
[:"a@127.0.0.1"]
```
