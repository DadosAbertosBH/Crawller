defmodule Crawler.BusCoordinates do
  use GenServer

  @moduledoc """
  Documentation for `Crawler`.
  """

  @doc """
  Starts the Crawler.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work(url \\ "https://dados.pbh.gov.br/datastore/dump/150bddd0-9a2c-4731-ade9-54aa56717fb6?bom=True") do

  end

  defp get_line_dictionary({lines, last_fetched}) do
    if Time.diff(Time.utc_now(), last_fetched) > 60 * 60 * 24 do # 24 hours
      url
      |> HTTPStream.get
      |> HTTPStream.lines
      |> CSV.decode!(headers: true)
      |> Stream.each(fn line -> lines.put(line["NumeroLinha"], line) end)
      |> run
    end
    lines
  end

  def watch(url \\ "https://temporeal.pbh.gov.br/?param=C") do
    url
    |> HTTPStream.get
    |> HTTPStream.lines
    |> CSV.decode!(separator: ?;, headers: true, strip_fields: true, validate_row_length: false)
    |> Stream.run
  end
end
