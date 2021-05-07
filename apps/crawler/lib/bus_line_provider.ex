defmodule Crawler.BusLineProvider do
  @moduledoc """
  Interface to get bus line
  """

  @doc """
  Dado a NumeroLinha (identificador da BH Trans),
  retorna um dicionário com as chaves NumeroLinha, LinhaNome \n\n

  NumeroLinha: identificador passado como parâmetro\n
  Linha: Número da linha do ônibus ex : 4403A-01\n
  Nome: Nome da linha do ônibus ex: ZOOLOGICO VIA SERRANO\n
  """
  @callback get(String.t()) ::
              {:ok,
               %{
                 NumeroLinha: String.t(),
                 Linha: String.t(),
                 Nome: String.t()
               }}
              | {:error, String.t()}
end
