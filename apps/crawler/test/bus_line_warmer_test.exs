defmodule BusLineWarmerTest do
  use ExUnit.Case
  use Assertions.Case

  test "when decode with success returns {:ok, [{id, %{NumeroLinha, Linha, Nome}}]" do
    bypass = Bypass.open()

    Bypass.expect(bypass, fn conn ->
      csv = """
      NumeroLinha;Linha;Nome
      2;0100-01;BARREIRO
      3;0100-02;BARREIRO
      """

      Plug.Conn.resp(conn, 200, csv)
    end)

    {:ok, [first | [second]]} = Crawler.BusLineWarmer.execute("http://localhost:#{bypass.port}/")

    assert first == {"2", %{"NumeroLinha" => "2", "Linha" => "0100-01", "Nome" => "BARREIRO"}}
    assert second == {"3", %{"NumeroLinha" => "3", "Linha" => "0100-02", "Nome" => "BARREIRO"}}
  end
end
