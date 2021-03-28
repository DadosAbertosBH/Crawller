defmodule Crawler.BusCoordinates do

  require Logger

  @moduledoc """
  Documentation for `BusCoordinates`.
  """

  @doc """
  Starts the Crawler.
  opts
    * `real_time_url`- Url to fetch bus coordinates, default to "https://temporeal.pbh.gov.br/?param=C"
    * `pull_interval`- Time in miliseconds that should be pulled"
  """
  def watch(opts) do
    default = [
      real_time_url: "https://temporeal.pbh.gov.br/?param=C",
      pull_interval: 60 * 1000
    ]
    options = Keyword.merge(default, opts)
    real_time_url = options[:real_time_url]
    pull_interval = options[:pull_interval]
    bus_line_provider = options[:bus_line_provider]

    Stream.interval(pull_interval)
    |> Stream.flat_map(fn _ -> HTTPStream.get(real_time_url) end)
    |> HTTPStream.lines()
    |> CSV.decode!(separator: ?;, headers: true, strip_fields: true, validate_row_length: false)
    |> Stream.map(fn row -> merge_with_bus_line(row, bus_line_provider) end)
  end

  defp merge_with_bus_line(row, bus_line_provider) do
    case bus_line_provider.get(row["NL"]) do
      {:error, reason} ->
        Logger.info("Failed to find bus line for #{row["NL"]}, reason: #{reason}")
        row
      {:ok, nil} ->
        Logger.info("Found nil cache for line #{row["NL"]}")
        row
      {:ok, bus_line} -> Map.merge(row, bus_line)
    end
  end
end
