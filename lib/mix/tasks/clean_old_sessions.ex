defmodule Mix.Tasks.CleanOldSessions do
  use Mix.Task
  require Logger

  @shortdoc "Deletes expired sessions"

  def run(_args) do
    [:logger, :myxql, :poison]
    |> Enum.each(&Application.ensure_all_started/1)

    {:ok, _} =
      MyXQL.start_link(
        username: System.get_env("DB_USERNAME"),
        hostname: System.get_env("DB_HOST"),
        password: System.get_env("DB_PASSWORD"),
        database: System.get_env("DB_DATABASE"),
        name: :db
      )

    count =
      "SELECT count(*) as 'count' FROM `session` where expire < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 14 day));"
      |> DB.query(:db)
      |> hd

    {:ok, metadata} = Poison.encode(count)
    Logger.info("Number of sessions to be cleaned. #{metadata}")

    "DELETE FROM `session` where expire < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 14 day));"
    |> DB.query(:db)

    Logger.info("Done.")
  end
end
