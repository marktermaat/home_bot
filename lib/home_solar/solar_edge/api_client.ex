defmodule HomeSolar.SolarEdge.ApiClient do
  use Retry

  alias HomeSolar.SolarEdge.EnergyValue
  alias HomeSolar.SolarEdge.EnergyDayValue
  alias HomeSolar.SolarEdge.TelemetryValue

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

    if response.status_code != 200 do
      HomeBot.Bot.notify_users("Error calling SolarEdge API. Response: ")
      HomeBot.Bot.notify_users(response.body)
    end

    Jason.decode!(response.body, keys: :atoms)
    |> Map.get(:energy, %{})
    |> Map.get(:values, [])
    |> Enum.map(&to_energy_value/1)
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

    Jason.decode!(response.body, keys: :atoms)
    |> Map.get(:energy, %{})
    |> Map.get(:values, [])
    |> Enum.map(&to_energy_day_value/1)
  end

  @spec get_telemetry_data(NaiveDateTime.t(), NaiveDateTime.t()) :: [%TelemetryValue{}]
  def get_telemetry_data(start_time, end_time) do
    HTTPoison.start()

    query_params = %{
      api_key: api_key(),
      startTime: Calendar.strftime(start_time, "%Y-%m-%d %H:%M:%S"),
      endTime: Calendar.strftime(end_time, "%Y-%m-%d %H:%M:%S")
    }

    {:ok, response} = call(telemetry_uri(query_params))

    Jason.decode!(response.body, keys: :atoms)
    |> Map.get(:data, %{})
    |> Map.get(:telemetries, [])
    |> Enum.map(&to_telemetry_value/1)
  end

  defp to_energy_value(record) do
    %EnergyValue{timestamp: convert_timestamp(record[:date]), value: record[:value]}
  end

  defp to_energy_day_value(record) do
    %EnergyDayValue{date: convert_date(record[:date]), value: record[:value]}
  end

  defp to_telemetry_value(record) do
    %TelemetryValue{
      timestamp: convert_timestamp(record[:date]),
      current_power: record[:totalActivePower],
      ac_voltage: record[:L1Data][:acVoltage],
      inverter_mode: record[:inverterMode]
    }
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
  defp inverter_serial_number, do: "7403C8B5-F4"
  defp api_key, do: Application.fetch_env!(:home_bot, :solar_edge_api_key)

  defp energy_uri(params), do: "#{host()}/site/#{site_id()}/energy?#{URI.encode_query(params)}"

  defp telemetry_uri(params),
    do:
      "#{host()}/equipment/#{site_id()}/#{inverter_serial_number()}/data?#{URI.encode_query(params)}"

  defp call(uri) do
    retry with: constant_backoff(1000) |> Stream.take(10) do
      HTTPoison.get(uri, recv_timeout: 15000)
    after
      result -> result
    else
      error -> error
    end
  end
end
