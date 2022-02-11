defmodule HomeSolar.SolarEdge.EnergyValue do
  @enforce_keys [:timestamp, :value]
  @derive Jason.Encoder
  defstruct [:timestamp, :value]

  @type t :: %HomeSolar.SolarEdge.EnergyValue{timestamp: NaiveDateTime.t(), value: float()}
end
