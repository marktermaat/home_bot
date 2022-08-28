defmodule HomeSolar.Api do
  alias HomeSolar.Api.SolarApi
  alias HomeSolar.Model.SolarPeriod

  @spec get_power_produced(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(SolarPeriod.t())
  def get_power_produced(start_time, end_time, group_quantity, group_unit) do
    SolarApi.get_power_produced(start_time, end_time, group_quantity, group_unit)
  end

  @spec get_latest_record() :: SolarPeriod.t()
  def get_latest_record() do
    SolarApi.get_latest_record()
  end
end
