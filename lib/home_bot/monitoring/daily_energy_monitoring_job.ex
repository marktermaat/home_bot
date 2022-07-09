defmodule HomeBot.Monitoring.DailyEnergyMonitoring do
  @moduledoc "This job will run some daily checks"

  alias HomeBot.Tools
  alias HomeEnergy.Api
  alias HomeWeather.Api, as: WeatherApi

  def run do
    check_gas_usage()
    check_electricity_usage()
  end

  def check_gas_usage do
    start_time = start_of_yesterday()
    end_time = end_of_yesterday()

    temperature_yesterday = get_average_temperature(start_time, end_time)
    gas_usage_yesterday = get_total_gas_usage(start_time, end_time)

    {mean, standard_deviation} = get_mean_std_gas_usage_for_temperature(temperature_yesterday)

    if gas_usage_yesterday < mean - 2 * standard_deviation do
      HomeBot.Bot.notify_users(
        "Gas usage yesterday was lower than expected. Yesterday it was #{gas_usage_yesterday}, normally it is #{mean} for the average temperature of #{temperature_yesterday}"
      )
    end

    if gas_usage_yesterday > mean + 2 * standard_deviation do
      HomeBot.Bot.notify_users(
        "Gas usage yesterday was higher than expected. Yesterday it was #{gas_usage_yesterday}, normally it is #{mean} for the average temperature of #{temperature_yesterday}"
      )
    end
  end

  def check_electricity_usage do
    start_time = start_of_yesterday()
    end_time = end_of_yesterday()
    weekday = Timex.weekday(Timex.now("Europe/Amsterdam") |> Timex.shift(days: -1))

    electricity_usage_yesterday = get_total_electricity_usage(start_time, end_time)
    {mean, standard_deviation} = get_mean_std_electricity_usage_for_weekday(weekday)

    if electricity_usage_yesterday < mean - 2 * standard_deviation do
      HomeBot.Bot.notify_users(
        "Electricity usage yesterday was lower than expected. Yesterday it was #{electricity_usage_yesterday}, normally it is #{mean} for this day of the week"
      )
    end

    if electricity_usage_yesterday > mean + 2 * standard_deviation do
      HomeBot.Bot.notify_users(
        "Electricity usage yesterday was higher than expected. Yesterday it was #{electricity_usage_yesterday}, normally it is #{mean} for this day of the week"
      )
    end
  end

  defp get_average_temperature(start_time, end_time) do
    WeatherApi.get_average_temperature(start_time, end_time)
    |> Decimal.round()
  end

  defp get_total_gas_usage(start_time, end_time) do
    Api.get_energy_usage(start_time, end_time, 1, "hour")
    |> Enum.reduce(0, fn x, acc -> acc + x.usage_gas end)
  end

  defp get_total_electricity_usage(start_time, end_time) do
    Api.get_energy_usage(start_time, end_time, 1, "hour")
    |> Enum.reduce(0, fn x, acc -> acc + x.usage_total_tariff end)
  end

  defp get_mean_std_gas_usage_for_temperature(temperature) do
    days_with_same_temperature =
      WeatherApi.get_average_temperature_per_day()
      |> Enum.filter(fn record ->
        record.temperature != nil &&
          record.temperature |> Decimal.round() |> Decimal.to_integer() == temperature
      end)
      |> Enum.map(fn record -> record.day_timestamp end)

    previous_usage =
      Api.get_energy_usage(~N[2000-01-01 00:00:00], NaiveDateTime.utc_now(), 1, "day")
      |> Enum.filter(fn period -> Enum.member?(days_with_same_temperature, period.start_time) end)
      |> Enum.map(fn x -> x.usage_gas end)

    mean = Tools.mean(previous_usage)
    standard_deviation = Tools.standard_deviation(previous_usage, mean)

    {mean, standard_deviation}
  end

  defp get_mean_std_electricity_usage_for_weekday(weekday) do
    historic_usage_values =
      Api.get_energy_usage(~N[2000-01-01 00:00:00], NaiveDateTime.utc_now(), 1, "day")
      |> Enum.filter(fn record -> Timex.weekday(record.start_time) == weekday end)
      |> Enum.map(fn x -> x.usage_total_tariff end)

    mean = Tools.mean(historic_usage_values)
    standard_deviation = Tools.standard_deviation(historic_usage_values, mean)

    {mean, standard_deviation}
  end

  defp start_of_yesterday do
    Timex.now("Europe/Amsterdam")
    |> Timex.beginning_of_day()
    |> Timex.shift(days: -1)
    |> DateTime.to_naive()
  end

  defp end_of_yesterday do
    Timex.now("Europe/Amsterdam") |> Timex.beginning_of_day() |> DateTime.to_naive()
  end
end
