# elixir-kiss

```bash
# install hex dependency manager
mix local.hex
# install phoenix
mix archive.install hex phx_new 1.4.9
mix phx.new . --app hello
mix deps.get
# database driver, expects postgres connection details in config/dev.exs
# make sure the database is running beforehand
mix ecto.create
cd assets && npm install && node node_modules/webpack/bin/webpack.js --mode development
cd ..
mix phx.server
# open browser to localhost:4000
```