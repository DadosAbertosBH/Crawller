defmodule Crawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Cachex.Spec

  @impl true
  def start(_type, _args) do
    source = {:service_account, get_google_auth("./apps/crawler/dadosabertosdebh.json"), []}
    stream = Crawler.BusCoordinates.watch(real_time_url: "https://temporeal.pbh.gov.br/?param=C")

    children = [
      {Ingestor.BigQuery,
       name: :big_query_injector,
       stream: stream,
       batch_size: 1000,
       project_id: "dadosabertosdebh",
       dataset_id: "dadosabertosdebh",
       table_id: "coordenadas_onibus"},
      {Goth, name: :goth, source: source},
      {Cachex,
       name: :app_cache,
       expiration: expiration(default: :timer.minutes(360)),
       warmers: [
         warmer(
           module: Crawler.BusLineWarmer,
           state:
             "https://ckan.pbh.gov.br/dataset/730aaa4b-d14c-4755-aed6-433cb0ad9430/resource/150bddd0-9a2c-4731-ade9-54aa56717fb6/download/bhtrans_bdlinha.csv"
         )
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crawler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_google_auth(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Jason.decode(body), do: json
  end
end
