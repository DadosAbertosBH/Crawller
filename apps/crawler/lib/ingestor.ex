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
    spawn_link(fn -> main(opts)  end)
    {:ok, opts}
  end

  def main(opts) do
    _table_id = get_table_id(opts)
    Crawler.BusCoordinates.watch(bus_line_provider: Crawler.CachexBusLineProvider)
    |> Stream.each(fn row ->
      IO.inspect(row)
      row
     end)
    |> Stream.run()
  end

  defp insert_rows(rows, opts) do
    response = GoogleApi.BigQuery.V2.Api.Tabledata.bigquery_tabledata_insert_all(
      connection(),
      opts.project_id,
      opts.dataset_id,
      opts.table_id,
      body: %GoogleApi.BigQuery.V2.Model.TableDataInsertAllRequest{
        rows: %GoogleApi.BigQuery.V2.Model.TableDataInsertAllRequestRows{
          json: GoogleApi.BigQuery.V2.Model.JsonObject.decode(rows, [])
          }
        }
    )
    case response do
    { :error, reason } ->
      Logger.info("Failed insert rows with error #{reason}")
    { :ok, _ } ->
      Logger.info("Rows inserted with success")
    end
  end

  defp connection do
    {:ok, %Goth.Token{token: token}} = Goth.Token.fetch(Crawler.Goth)
    GoogleApi.BigQuery.V2.Connection.new(token)
  end

  defp get_table_id(state) do
    conn = connection()

    #{:ok, table_list} = GoogleApi.BigQuery.V2.Api.Tables.bigquery_tables_list(conn, state.project_id, state.dataset_id)
    #table_list.tables()
    #|> Enum.filter(fn table -> table.friendlyName == state.table_name end)
    #|> Enum.map(fn table -> table.id end)
  end
end
