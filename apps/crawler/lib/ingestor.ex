defmodule Ingestor.BigQuery do
  require Logger
  use GenServer

  @type opts :: [
          project_id: String.t(),
          dataset_id: String.t(),
          project_id: String.t(),
          stream: Enumerable.t(),
          batch_size: integer
        ]

  @moduledoc """
  Documentation for `Ingestor.BigQuery`.

  """

  @doc """
  Starts the Ingestor.\n\n
  opts
    `batch_size`: default `100`\n
    `stream`: Stream to subscribe for rows\n
    `project_id`: Google cloud project id\n
    `dataset_id`: Big Query Dataset id\n
    `table_id`: Big Query Table to insert rows
  """
  @spec start_link(opts) :: {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  @spec init(opts) :: {:ok, pid()}
  def init(opts) do
    spawn_link(fn -> main(opts) end)
    {:ok, opts}
  end

  @spec main(opts) :: :ok
  def main(opts) do
    opts[:stream]
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
      {:error, _reason} ->
        Logger.error("Failed insert rows with error")
      {:ok, _response} ->
        Logger.info("Rows inserted with success")
    end
  end

  defp connection do
    {:ok, token} = Goth.fetch(:goth)
    GoogleApi.BigQuery.V2.Connection.new(token.token)
  end
end
