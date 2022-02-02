defmodule HomeJobs.SolarEdge.EnergyDayValue do
  @enforce_keys [:date, :value]
  @derive Jason.Encoder
  defstruct [:date, :value]

  @type t :: %HomeJobs.SolarEdge.EnergyDayValue{date: Date.t(), value: float()}
end
