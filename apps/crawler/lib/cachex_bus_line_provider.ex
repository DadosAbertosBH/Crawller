defmodule Crawler.CachexBusLineProvider do
  @behaviour Crawler.BusLineProvider

  @impl Crawler.BusLineProvider

  @doc """
  Dado a NumeroLinha (identificador da BH Trans),
  retorna um dicionário com as chaves NumeroLinha, Linha e Nome \n\n

  NumeroLinha: identificador passado como parâmetro\n
  Linha: Número da linha do ônibus ex : 4403A-01\n
  Nome: Nome da linha do ônibus ex: ZOOLOGICO VIA SERRANO\n
  """
  @spec get(String.t()) ::
              {:ok,
               %{
                 NumeroLinha: String.t(),
                 Linha: String.t(),
                 Nome: String.t()
               }}
              | {:error, String.t()}
  def get(bus_line_number), do: Cachex.get(:app_cache, bus_line_number)
end
