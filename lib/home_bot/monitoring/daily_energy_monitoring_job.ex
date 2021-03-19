defmodule HomeBot.Monitoring.DailyEnergyMonitoring do
  @moduledoc "This job will run some daily checks"

  alias HomeBot.DataStore
  alias HomeBot.Tools

  def run do
    check_gas_usage()
  end

  def check_gas_usage do
    start_time = Timex.now("Europe/Amsterdam") |> Timex.beginning_of_day() |> Timex.shift(days: -1) |> DateTime.to_iso8601()
    end_time = Timex.now("Europe/Amsterdam") |> Timex.beginning_of_day() |> DateTime.to_iso8601()

    temperature_yesterday = get_average_temperature(start_time, end_time)
    gas_usage_yesterday = get_total_gas_usage(start_time, end_time)

    {mean, standard_deviation} = get_mean_std_gas_usage_for_temperature(temperature_yesterday)

    if gas_usage_yesterday < mean - 2 * standard_deviation do
      HomeBot.Bot.notify_users("Gas usage yesterday was lower than expected. Yesterday it was #{gas_usage_yesterday}, normally it is #{mean} for the average temperature of #{temperature_yesterday}")
    end

    if gas_usage_yesterday > mean + 2 * standard_deviation do
      HomeBot.Bot.notify_users("Gas usage yesterday was higher than expected. Yesterday it was #{gas_usage_yesterday}, normally it is #{mean} for the average temperature of #{temperature_yesterday}")
    end
  end

  def check_electricity_usage do
    start_time = Timex.now("Europe/Amsterdam") |> Timex.beginning_of_day() |> Timex.shift(days: -1) |> DateTime.to_iso8601()
    end_time = Timex.now("Europe/Amsterdam") |> Timex.beginning_of_day() |> DateTime.to_iso8601()

    _electricity_usage_yesterday = get_total_electricity_usage(start_time, end_time)
  end

  defp get_average_temperature(start_time, end_time) do
    %{"temperature" => temperature} = DataStore.get_average_temperature(start_time, end_time)
    round(temperature)
  end

  defp get_total_gas_usage(start_time, end_time) do
    DataStore.get_gas_usage("1h", start_time, end_time)
    |> Enum.reduce(0, fn x, acc -> acc + x["usage"] end)
  end

  defp get_total_electricity_usage(start_time, end_time) do
    DataStore.get_electricity_usage("1h", start_time, end_time)
    |> Enum.reduce(0, fn x, acc -> acc + x["low_tariff_usage"] + x["normal_tariff_usage"] end)
  end

  defp get_mean_std_gas_usage_for_temperature(temperature) do
    days_with_same_temperature = HomeBot.DataStore.get_average_temperature_per_day(:all)
    |> Enum.filter(fn %{"temperature" => temp} -> round(temp) == temperature end)
    |> Enum.map(fn %{"time" => time} -> time end)

    previous_usage = DataStore.get_gas_usage_per_day(:all)
    |> Enum.filter(fn %{"time" => time} -> Enum.member?(days_with_same_temperature, time) end)
    |> Enum.map(fn x -> x["usage"] end)

    mean = Tools.mean(previous_usage)
    standard_deviation = Tools.standard_deviation(previous_usage, mean)
    {mean, standard_deviation}
  end
end
