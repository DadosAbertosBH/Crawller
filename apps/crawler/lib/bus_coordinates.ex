defmodule Crawler.BusCoordinates do
  @derive [Poison.Encoder]
  defstruct [
    :codigo_linha,
    :codigo_evento,
    :codigo_do_veiculo,
    :timestamp,
    :coordenadas,
    :velocidade_instantanea,
    :distancia_pecorrida,
    :direcao_do_veiculo,
    :sentindo_da_viagem,
    :numero_linha,
    :nome_linha
  ]

  @typedoc """
  BusCoordinates

  Representa o conjunto de dados tempo [Real Ônibus - Coordenada atualizada](https://dados.pbh.gov.br/dataset/tempo_real_onibus_-_coordenada)
  * [Dicionário de dados](https://ckan.pbh.gov.br/dataset/730aaa4b-d14c-4755-aed6-433cb0ad9430/resource/825337e5-8cd5-43d9-ac52-837d80346721/download/dicionario_arquivo.csv)
  * [Arquivode conversão das linhas do sistema concencional](https://dados.pbh.gov.br/dataset/tempo_real_onibus_-_coordenada/resource/150bddd0-9a2c-4731-ade9-54aa56717fb6)

  Dados disponíveis publicamente no [BigQuery](https://console.cloud.google.com/bigquery?project=dadosabertosdebh&p=dadosabertosdebh&page=table&d=dadosabertosdebh&t=coordenadas_onibus)\n

  `:codigo_linha` NL - Código interno da linha\n
  `:codigo_evento` EV - Código do evento, 105 representa o evento de coordenadas\n
  `:codigo_do_veiculo` NV - Código do veículo\n
  `:timestamp` HR - Timestamp do evento\n
  `:coordenadas` LT, LG - Coordenada do veículo\n
  `:velocidade_instantanea` VL - Velocidade instantânea do veículo\n
  `:distancia_pecorrida` DT - Distância percorrida\n
  `:direcao_do_veiculo` DG - Direção do veículo\n
  `:sentindo_da_viagem` SV - Sentido do veículo em uma viagem ((1) ida, (2) volta)\n
  `:numero_linha` - Número da linha do ônibus\n
  `:nome_linha` - Nome da linha do ônibus\n
  """
  @type t :: %__MODULE__{
          codigo_linha: String.t(),
          codigo_evento: String.t(),
          codigo_do_veiculo: String.t(),
          timestamp: float(),
          coordenadas: struct(),
          velocidade_instantanea: float(),
          distancia_pecorrida: float(),
          direcao_do_veiculo: String.t(),
          sentindo_da_viagem: String.t(),
          numero_linha: String.t(),
          nome_linha: String.t()
        }

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
    bus_coordinates = decode_bus_coordinates(row)

    case bus_line_provider.get(bus_coordinates.codigo_linha) do
      {:error, reason} ->
        Logger.info("Failed to find bus line for #{row["NL"]}, reason: #{reason}")
        bus_coordinates

      {:ok, nil} ->
        Logger.info("Found nil cache for line #{row["NL"]}")
        bus_coordinates

      {:ok, bus_line} ->
        %{bus_coordinates | numero_linha: bus_line["Linha"], nome_linha: bus_line["Nome"]}
    end
  end

  defp decode_bus_coordinates(row) do
    geoPoint = %Geo.Point{coordinates: {parse_decimal(row["LT"]), parse_decimal(row["LG"])}}

    %Crawler.BusCoordinates{
      codigo_linha: row["NL"],
      codigo_evento: row["EV"],
      codigo_do_veiculo: row["NV"],
      timestamp: Timex.parse!(row["HR"], "%Y%m%d%H%M%S", :strftime),
      coordenadas: Geo.JSON.encode!(geoPoint) |> Poison.encode!(),
      velocidade_instantanea: parse_decimal(row["VL"]),
      distancia_pecorrida: parse_decimal(row["DT"]),
      direcao_do_veiculo: row["DG"],
      sentindo_da_viagem: row["SV"]
    }
  end

  defp parse_decimal(nil) do
    nil
  end

  defp parse_decimal(value) do
    br_decimal = value |> String.replace(",", ".")
    {decimal, _} = Float.parse(br_decimal)
    decimal
  end
end
