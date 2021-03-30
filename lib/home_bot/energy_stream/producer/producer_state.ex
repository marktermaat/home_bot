defmodule HomeBot.EnergyStream.Producer.ProducerState do
  defstruct events: :queue.new(), demand: 0, latest_measurement: Timex.now()
end
