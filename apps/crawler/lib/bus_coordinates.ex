defmodule Crawler do

  @moduledoc """
  Documentation for `Crawler`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Crawler.hello()
      :world

  """
  def busCoordinates(url \\ "https://temporeal.pbh.gov.br/?param=C") do
    url
    |> HTTPStream.get()
    |> HTTPStream.lines()
    |> CSV.decode!(separator: ?;, headers: true, strip_fields: true, validate_row_length: false)
  end
end
