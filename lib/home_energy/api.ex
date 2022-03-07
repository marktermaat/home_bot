defmodule HomeEnergy.Api do
  alias HomeEnergy.Api.EnergyApi
  alias HomeEnergy.Model.EnergyPeriod

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(EnergyPeriod.t())
  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    EnergyApi.get_energy_usage(start_time, end_time, group_quantity, group_unit)
  end
end
