defmodule HomeJobs.SolarEdge.ApiClient do
  use Retry

  alias HomeJobs.SolarEdge.EnergyValue
  alias HomeJobs.SolarEdge.EnergyDayValue

  @spec get_quarter_energy_data(Date.t(), Date.t()) :: [%EnergyValue{}]
  def get_quarter_energy_data(start_date, end_date) do
    HTTPoison.start()

    query_params = %{
      api_key: api_key(),
      startDate: Date.to_string(start_date),
      endDate: Date.to_string(end_date),
      timeUnit: "QUARTER_OF_AN_HOUR"
    }

    {:ok, response} = call(energy_uri(query_params))

    data = Jason.decode!(response.body, keys: :atoms)

    data[:energy][:values]
    |> Enum.map(fn record ->
      %EnergyValue{timestamp: convert_timestamp(record[:date]), value: record[:value]}
    end)
  end

  @spec get_daily_energy_data(Date.t(), Date.t()) :: [%EnergyDayValue{}]
  def get_daily_energy_data(start_date, end_date) do
    HTTPoison.start()

    query_params = %{
      api_key: api_key(),
      startDate: Date.to_string(start_date),
      endDate: Date.to_string(end_date),
      timeUnit: "DAY"
    }

    {:ok, response} = call(energy_uri(query_params))

    data = Jason.decode!(response.body, keys: :atoms)

    data[:energy][:values]
    |> Enum.map(fn record ->
      %EnergyDayValue{date: convert_date(record[:date]), value: record[:value]}
    end)
  end

  defp convert_timestamp(timestamp) do
    timezone = Timex.Timezone.get("Europe/Amsterdam")

    timestamp
    |> Timex.parse!("{ISOdate} {ISOtime}")
    |> Timex.Timezone.convert(timezone)
    |> Timex.to_naive_datetime()
  end

  defp convert_date(date) do
    date
    |> Timex.parse!("{ISOdate} {ISOtime}")
    |> Timex.to_date()
  end

  defp host, do: "https://monitoringapi.solaredge.com"
  defp site_id, do: "2549602"
  defp api_key, do: Application.fetch_env!(:home_bot, :solar_edge_api_key)

  defp energy_uri(params), do: "#{host()}/site/#{site_id()}/energy?#{URI.encode_query(params)}"

  defp call(uri) do
    retry with: constant_backoff(1000) |> Stream.take(10) do
      HTTPoison.get(uri, [recv_timeout: 5000])
    after
      result -> result
    else
      error -> error
    end
  end
end
