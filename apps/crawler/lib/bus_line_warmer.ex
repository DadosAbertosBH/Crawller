defmodule Crawler.BusLineWarmer do
  @moduledoc """
  BusLineWarmer warmer which caches database from service.
  """
  use Cachex.Warmer

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.minutes(180)

  @doc """
  Executes this cache warmer with a connection.
  """
  def execute(url) do
    list = url
    |> HTTPStream.get
    |> HTTPStream.lines
    |> Stream.map(fn line -> :unicode.characters_to_binary(line, :latin1) end)
    |> CSV.decode!(separator: ?;, headers: true)
    |> Enum.map(fn line -> { line["NumeroLinha"], line } end)
    |> Enum.to_list()
    { :ok, list}
  end
end
