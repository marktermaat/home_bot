defmodule HomeEnergy.Model.EnergyPeriod do
  @derive Jason.Encoder
  @enforce_keys [:start_time]
  defstruct [
    :start_time,
    :usage_low_tariff,
    :supplied_low_tariff,
    :usage_normal_tariff,
    :supplied_normal_tariff,
    :usage_total_tariff,
    :supplied_total_tariff,
    :usage_gas
  ]

  @type t :: %HomeEnergy.Model.EnergyPeriod{
          start_time: NaiveDateTime.t(),
          usage_low_tariff: float(),
          supplied_low_tariff: float(),
          usage_normal_tariff: float(),
          supplied_normal_tariff: float(),
          usage_total_tariff: float(),
          supplied_total_tariff: float(),
          usage_gas: float()
        }
end
