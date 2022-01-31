defmodule HomeJobs.SolarEdge.ApiClient do
  alias HomeJobs.SolarEdge.EnergyValue

  @spec get_quarter_energy_data(Date.t(), Date.t()) :: [%EnergyValue{}]
  def get_quarter_energy_data(start_date, end_date) do
    HTTPoison.start()

    query_params = %{
      api_key: api_key(),
      startDate: Date.to_string(start_date),
      endDate: Date.to_string(end_date),
      timeUnit: "QUARTER_OF_AN_HOUR"
    }

    {:ok, response} = HTTPoison.get(energy_uri(query_params))
    data = Jason.decode!(response.body, keys: :atoms)

    data[:energy][:values]
    |> Enum.map(fn record ->
      %EnergyValue{timestamp: convert_timestamp(record[:date]), value: record[:value]}
    end)
  end

  defp convert_timestamp(timestamp) do
    timezone = Timex.Timezone.get("Europe/Amsterdam")

    timestamp
    |> Timex.parse!("{ISOdate} {ISOtime}")
    |> Timex.Timezone.convert(timezone)
    |> Timex.to_naive_datetime()
  end

  def host, do: "https://monitoringapi.solaredge.com"
  def site_id, do: "2549602"
  def api_key, do: Application.fetch_env!(:home_bot, :solar_edge_api_key)

  def energy_uri(params) do
    "#{host()}/site/#{site_id()}/energy?#{URI.encode_query(params)}"
  end
end
