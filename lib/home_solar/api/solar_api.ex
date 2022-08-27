defmodule HomeSolar.Api.SolarApi do
  alias HomeSolar.Api.Repo

  @spec get_power_produced(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(SolarPeriod.t())
  def get_power_produced(start_time, end_time, group_quantity, group_unit) do
    Repo.get_power_produced(start_time, end_time, group_quantity, group_unit)
  end

  @spec get_latest_record() :: SolarPeriod.t()
  def get_latest_record() do
    Repo.get_latest_record()
  end
end
