defmodule Crawler.CachexBusLineProvider do
  @behaviour Crawler.BusLineProvider

  @impl Crawler.BusLineProvider
  def get(bus_line_number), do: Cachex.get(:app_cache, bus_line_number)
end
