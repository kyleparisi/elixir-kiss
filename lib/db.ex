defmodule DB do
  def paginate(query) do
    query = String.replace(query, ";", "") |> String.trim()
    query <> " LIMIT 0,100;"
  end

  def paginate(query, page) do
    query = String.replace(query, ";", "") |> String.trim()
    query <> " LIMIT #{page * 100},#{page * 100 + 100};"
  end

  def query(query, repo, params \\ []) do
    MyXQL.query(repo, query, params) |> to_maps
  end

  # Insert
  def to_maps({:ok, %MyXQL.Result{last_insert_id: id, columns: nil, rows: nil}}) when id > 0 do
    %{id: id}
  end

  # Update/Delete
  def to_maps({:ok, %MyXQL.Result{last_insert_id: 0, columns: nil, rows: nil}}) do
    :ok
  end

  # Select
  def to_maps({:ok, %MyXQL.Result{columns: columns, rows: rows}}) do
    Enum.map(rows, fn row ->
      columns
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
  end
end
