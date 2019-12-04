defmodule Validations do
  def validate_integer(key, value) do
    case Integer.parse(value) do
      :error -> {key, {:error, "could not parse #{value} as integer"}}
      {int, _} -> {key, int}
    end
  end
end
