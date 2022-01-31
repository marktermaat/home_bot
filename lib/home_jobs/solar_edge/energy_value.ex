defmodule HomeJobs.SolarEdge.EnergyValue do
  @enforce_keys [:timestamp, :value]
  @derive Jason.Encoder
  defstruct [:timestamp, :value]

  @type t :: %HomeJobs.SolarEdge.EnergyValue{timestamp: NaiveDateTime.t(), value: float()}
end
