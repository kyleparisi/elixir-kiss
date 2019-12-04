defmodule Validations do
  def validate_integer(key, value) do
    case Integer.parse(value) do
      :error -> {key, {:error, "could not parse #{value} as integer"}}
      {int, _} -> {key, int}
    end
  end

  def validate_not_empty(key, nil), do: {key, {:error, "Missing #{key}."}}

  def validate_not_empty(key, value) do
    case byte_size(value) do
      0 -> {key, {:error, "Missing #{key}."}}
      _ -> {key, value}
    end
  end
end
