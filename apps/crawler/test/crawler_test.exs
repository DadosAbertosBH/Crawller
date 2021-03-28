defmodule CrawlerTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "test parse CSV", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, """
      EV; HR; LT; LG; NV; VL; NL; DG; SV; DT
      105;20210323162012;-19,868567;-44,014435;40867;0;357;0;0;708
      105;20210323162108;-19,927357;-44,006144;40559;26;4023;14
      """)
    end)

    response = Crawler.BusCoordinates.watch(
      real_time_url: "http://localhost:#{bypass.port}/",
      pull_interval: 1,
      bus_line_provider: CrawlerTest.MockBusLineProvider)
    |> Stream.take(2)
    |> Enum.to_list()
    assert response == [
      %{
        "DG" => "0",
        "DT" => "708",
        "EV" => "105",
        "HR" => "20210323162012",
        "LG" => "-44,014435",
        "LT" => "-19,868567",
        "NL" => "357",
        "NV" => "40867",
        "SV" => "0",
        "VL" => "0",
        "NumeroLinha" => "357",
        "Linha" => "4403A-01",
        "Nome" => "ZOOLOGICO VIA SERRANO"
      },
      %{
        "DG" => "14",
        "EV" => "105",
        "HR" => "20210323162108",
        "LG" => "-44,006144",
        "LT" => "-19,927357",
        "NL" => "4023",
        "NV" => "40559",
        "VL" => "26",
        "NumeroLinha" => "4023",
        "Linha" => "6350",
        "Nome" => "EST.VILAR./EST.BARREIRO-VIA ANEL"
      }
    ]
  end

  defmodule MockBusLineProvider do
    @behaviour Crawler.BusLineProvider

    @impl Crawler.BusLineProvider
    def get("357") do {:ok, %{
      "NumeroLinha" => "357",
      "Linha" => "4403A-01",
      "Nome" => "ZOOLOGICO VIA SERRANO"
    }} end
    def get("4023") do {:ok, %{
      "NumeroLinha" => "4023",
      "Linha" => "6350",
      "Nome" => "EST.VILAR./EST.BARREIRO-VIA ANEL"
    }} end
  end
end
