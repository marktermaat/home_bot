defmodule HomeEnergy.Api.EnergyApi do
  alias HomeEnergy.Model.EnergyPeriod
  alias HomeEnergy.Repo.EnergyRepo

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(EnergyPeriod.t())
  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    EnergyRepo.get_energy_usage(start_time, end_time, group_quantity, group_unit)
  end
end
