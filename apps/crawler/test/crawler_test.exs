defmodule CrawlerTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    crawler = start_supervised!(Crawler.BusCoordinates)
    {:ok, bypass: bypass, crawler: crawler}
  end

  test "test parse CSV", %{bypass: bypass, crawler: crawler} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, """
      EV; HR; LT; LG; NV; VL; NL; DG; SV; DT
      105;20210323162012;-19,868567;-44,014435;40867;0;357;0;0;708
      105;20210323162108;-19,927357;-44,006144;40559;26;4023;14
      """)
    end)

    stream = Crawler.BusCoordinates.watch("http://localhost:#{bypass.port}/")
    response = Enum.to_list(stream)
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
        "VL" => "0"
      },
      %{
        "DG" => "14",
        "EV" => "105",
        "HR" => "20210323162108",
        "LG" => "-44,006144",
        "LT" => "-19,927357",
        "NL" => "4023",
        "NV" => "40559",
        "VL" => "26"
      }
    ]
  end
end
