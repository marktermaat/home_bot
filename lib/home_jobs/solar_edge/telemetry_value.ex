defmodule HomeJobs.SolarEdge.TelemetryValue do
  @derive Jason.Encoder
  @enforce_keys [:timestamp, :current_power, :inverter_mode]
  defstruct [:timestamp, :current_power, :inverter_mode]

  @type t :: %HomeJobs.SolarEdge.TelemetryValue{
          timestamp: NaiveDateTime.t(),
          current_power: float(),
          inverter_mode: String.t()
        }
end
