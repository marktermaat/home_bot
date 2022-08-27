defmodule HomeSolar.Model.SolarPeriod do
  @derive Jason.Encoder
  @enforce_keys [:timestamp, :power_produced]
  defstruct [
    # The start timestamp of this period in local time
    :timestamp,
    # The power produced in this period in Wh
    :power_produced
  ]

  @type t :: %HomeSolar.Model.SolarPeriod{
          timestamp: NaiveDateTime.t(),
          power_produced: integer()
        }
end
