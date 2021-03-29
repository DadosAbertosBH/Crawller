defmodule Crawler.BusLineProvider do
  @doc """
  Parses a string.
  """
  @callback get(String.t()) :: {:ok, %{}} | {:error, String.t()}
end
