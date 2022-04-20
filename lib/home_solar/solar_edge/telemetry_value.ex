defmodule HomeSolar.SolarEdge.TelemetryValue do
  @derive Jason.Encoder
  @enforce_keys [:timestamp, :current_power, :ac_voltage, :inverter_mode]
  defstruct [:timestamp, :current_power, :ac_voltage, :inverter_mode]

  @type t :: %HomeSolar.SolarEdge.TelemetryValue{
          timestamp: NaiveDateTime.t(),
          current_power: float(),
          ac_voltage: float(),
          inverter_mode: String.t()
        }
end
