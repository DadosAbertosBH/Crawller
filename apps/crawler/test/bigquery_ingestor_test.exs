defmodule BigQueryIngestorTest do
  use ExUnit.Case, async: true
  use Assertions.Case

  test "when decode with success returns {:ok, [{id, %{NumeroLinha, Linha, Nome}}]" do
    bypass = Bypass.open()

    Application.put_env(:google_api_big_query, :base_url, "http://localhost:#{bypass.port}/")

    Bypass.expect(bypass, fn conn ->
      IO.inspect(conn)

      assert conn.request_path ==
               "/bigquery/v2/projects/dadosabertosdebh/datasets/dadosabertosdebh/tables/coordenadas_onibus/insertAll"

      Plug.Conn.resp(conn, 200, "{}")
    end)

    stream = [
      %Crawler.BusCoordinates{
        codigo_evento: "105",
        timestamp: ~N[2021-03-23 16:20:12],
        coordenadas: "{\"type\":\"Point\",\"coordinates\":[-19.868567,-44.014435]}",
        codigo_do_veiculo: "40867",
        velocidade_instantanea: 0.0,
        codigo_linha: "357",
        direcao_do_veiculo: "0",
        distancia_pecorrida: 708.0,
        nome_linha: "ZOOLOGICO VIA SERRANO",
        numero_linha: "4403A-01",
        sentindo_da_viagem: "0"
      }
    ]

    :ok =
      Ingestor.BigQuery.main(
        batch_size: 1,
        stream: Stream.take(stream, 1),
        project_id: "dadosabertosdebh",
        dataset_id: "dadosabertosdebh",
        table_id: "coordenadas_onibus"
      )
  end
end
