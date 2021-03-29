inputs = %{
  "batch_size_1000" => 1000,
  "batch_size_2000" => 2000,
  "batch_size_5000" => 5000,
}

stream = Stream.cycle([%Crawler.BusCoordinates{
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
}])


Benchee.run(%{
    "big_query_injector" => fn batch_size ->
      Ingestor.BigQuery.main(batch_size: batch_size,stream: Stream.take(stream, 5000),project_id: "dadosabertosdebh",dataset_id: "dadosabertosdebh",table_id: "coordenadas_onibus")
    end
  },
  inputs: inputs
)
