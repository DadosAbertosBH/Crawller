defmodule CrawlerTest do
  use ExUnit.Case
  use Assertions.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "When fail to decode decimal, then fallback to 0.0", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, """
      EV; HR; LT; LG; NV; VL; NL; DG; SV; DT
      105;20210323162012;-LG;-44,014435;40867;0;357;0;0;708
      105;20210323162108;-19,927357;-44,006144;40559;26;4023;14
      """)
    end)

    response =
      Crawler.BusCoordinates.watch(
        real_time_url: "http://localhost:#{bypass.port}/",
        pull_interval: 1,
        bus_line_provider: CrawlerTest.MockBusLineProvider
      )
      |> Stream.take(1)
      |> Enum.to_list()

    assert_lists_equal(
      response,
      [
        %Crawler.BusCoordinates{
          codigo_evento: "105",
          timestamp: ~N[2021-03-23 16:20:12],
          coordenadas: "{\"type\":\"Point\",\"coordinates\":[0.0,-44.014435]}",
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
    )
  end

  test "test parse CSV", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, """
      EV; HR; LT; LG; NV; VL; NL; DG; SV; DT
      105;20210323162012;-19,868567;-44,014435;40867;0;357;0;0;708
      105;20210323162108;-19,927357;-44,006144;40559;26;4023;14
      """)
    end)

    response =
      Crawler.BusCoordinates.watch(
        real_time_url: "http://localhost:#{bypass.port}/",
        pull_interval: 1,
        bus_line_provider: CrawlerTest.MockBusLineProvider
      )
      |> Stream.take(2)
      # |> Stream.each(fn x -> IO.inspect(x) end)
      |> Enum.to_list()

    assert_lists_equal(
      response,
      [
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
        },
        %Crawler.BusCoordinates{
          codigo_do_veiculo: "40559",
          codigo_evento: "105",
          codigo_linha: "4023",
          coordenadas: "{\"type\":\"Point\",\"coordinates\":[-19.927357,-44.006144]}",
          direcao_do_veiculo: "14",
          distancia_pecorrida: nil,
          nome_linha: "EST.VILAR./EST.BARREIRO-VIA ANEL",
          numero_linha: "6350",
          sentindo_da_viagem: nil,
          timestamp: ~N[2021-03-23 16:21:08],
          velocidade_instantanea: 26.0
        }
      ]
    )
  end

  defmodule MockBusLineProvider do
    @behaviour Crawler.BusLineProvider

    @impl Crawler.BusLineProvider
    def get("357") do
      {:ok,
       %{
         "NumeroLinha" => "357",
         "Linha" => "4403A-01",
         "Nome" => "ZOOLOGICO VIA SERRANO"
       }}
    end

    def get("4023") do
      {:ok,
       %{
         "NumeroLinha" => "4023",
         "Linha" => "6350",
         "Nome" => "EST.VILAR./EST.BARREIRO-VIA ANEL"
       }}
    end
  end
end
