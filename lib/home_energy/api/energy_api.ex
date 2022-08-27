defmodule HomeEnergy.Api.EnergyApi do
  alias HomeEnergy.Model.EnergyPeriod
  alias HomeEnergy.Repo.EnergyRepo

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(EnergyPeriod.t())
  def get_energy_usage(start_time, end_time, group_quantity, "day") do
    EnergyRepo.get_energy_usage(start_time, end_time, group_quantity, "day")
  end

  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    start_time_utc =
      start_time
      |> Timex.to_datetime("Europe/Amsterdam")
      |> Timex.to_naive_datetime()

    end_time_utc =
      end_time
      |> Timex.to_datetime("Europe/Amsterdam")
      |> Timex.to_naive_datetime()

    EnergyRepo.get_energy_usage(start_time_utc, end_time_utc, group_quantity, group_unit)
    |> Enum.map(&convert_time_to_local/1)
  end

  defp convert_time_to_local(energy_period) do
    local_time = energy_period.start_time
    |> Timex.Timezone.convert("Europe/Amsterdam")
    |> DateTime.to_naive()
    %{energy_period | start_time: local_time}
  end
end
