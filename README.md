# elixir-kiss

## Usage

```bash
mix deps.get
iex -S mix
# if you already have aws cli configured...
iex(3)> ExAws.Dynamo.get_item("sessions", %{id: "sess:6yOOfHbJrsio0PRgLbo8RarfvuXsZOCw"}) |> ExAws.request
{:ok,
 %{
   "Item" => %{
     "expires" => %{"N" => "1564537223"},
     "id" => %{"S" => "sess:6yOOfHbJrsio0PRgLbo8RarfvuXsZOCw"},
     "sess" => %{
       "S" => "{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"}}"
     },
     "type" => %{"S" => "connect-session"}
   }
 }}
```
