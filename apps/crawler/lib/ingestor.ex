defmodule Ingestor.BigQuery do
  require Logger
  use GenServer

  @moduledoc """
  Documentation for `BusCoordinates`.
  """

  @doc """
  Starts the Crawler.
  opts
    * `project_id`
    * `dataset_id`
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    spawn_link(fn -> main(opts) end)
    {:ok, opts}
  end

  def main(opts) do
    Crawler.BusCoordinates.watch(bus_line_provider: Crawler.CachexBusLineProvider)
    |> Stream.map(fn row -> GoogleApi.BigQuery.V2.Model.JsonObject.decode(row, []) end)
    |> Stream.map(fn json ->
      %GoogleApi.BigQuery.V2.Model.TableDataInsertAllRequestRows{json: json}
    end)
    |> Stream.chunk_every(opts[:batch_size])
    |> Stream.each(fn rows ->
      insert_rows(rows, opts)
    end)
    |> Stream.run()
  end

  defp insert_rows(rows, opts) do
    response =
      GoogleApi.BigQuery.V2.Api.Tabledata.bigquery_tabledata_insert_all(
        connection(),
        opts[:project_id],
        opts[:dataset_id],
        opts[:table_id],
        body: %GoogleApi.BigQuery.V2.Model.TableDataInsertAllRequest{
          rows: rows
        }
      )

    case response do
      {:error, reason} ->
        Logger.error("Failed insert rows with error")
        IO.inspect(reason)

      {:ok, _response} ->
        Logger.info("Rows inserted with success")
    end
  end

  defp connection do
    {:ok, token} = Goth.fetch(:goth)
    GoogleApi.BigQuery.V2.Connection.new(token.token)
  end
end
