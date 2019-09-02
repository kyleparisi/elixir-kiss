# elixir-kiss

## Usage

```bash
mix deps.get
# server 1, cookies are requied when dealing with remote machines
# Your server will also need an IAM role that has the ability to 
# describe instances.
iex --name app@10.0.0.35 --cookie test -S mix
# server 2
iex --name app@10.0.0.168 --cookie test -S mix
```
