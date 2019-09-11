defmodule MyApp.User do
  use Ecto.Schema

  schema "user" do
    field :name, :string, null: false
    field :email, :string, null: false
    field :forgot_token, :string
  end
end