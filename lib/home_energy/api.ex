defmodule HomeEnergy.Api do
  alias HomeEnergy.Api.EnergyApi
  alias HomeEnergy.Model.EnergyPeriod

  @doc """
  Retrieve the energy usage in the given period, aggregated by the given grouping
  ## Parameters
  - start_time: The start time of the period in **local** time
  - end_time: The end time of the period in **local** time
  - group_quantity: The quantity of the groupinig (say, the `5` in `5 minutes`)
  - group_unit: The unit of the groupinig (say `minutes` or `days`)
  """
  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(EnergyPeriod.t())
  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    EnergyApi.get_energy_usage(start_time, end_time, group_quantity, group_unit)
  end
end
