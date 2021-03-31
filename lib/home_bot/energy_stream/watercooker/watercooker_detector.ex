defmodule HomeBot.EnergyStream.Watercooker.WatercookerDetector do
  use GenStage

  alias HomeBot.EnergyStream.Watercooker.State

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok)
  end

  @impl GenStage
  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, %State{}, subscribe_to: [HomeBot.EnergyStream.Producer.EnergyProducer]}
  end

  @impl GenStage
  @spec handle_events(any, any, %State{}) :: {:noreply, [], any}
  def handle_events(events, _from, state) do
    state = Enum.reduce(events, state, fn event, state ->
      handle_event(event, state)
    end)
    {:noreply, [], state}
  end

  defp handle_event(event, state) do
    energy_difference = event["current_energy_usage"] - state.previous_usage
    {:ok, now, _} = DateTime.from_iso8601(event["time"])
    cond do
      detection_inactive?(state) && watercooker_on?(energy_difference) ->
        # IO.puts("Started!")
        %{state | previous_usage: event["current_energy_usage"], active_since: now, usage: energy_difference}
      detection_active?(state) && watercooker_off?(energy_difference) && active_long_enough?(state.active_since, now) ->
        HomeBot.Bot.notify_users("Watercooker used at #{in_timezone(state.active_since)} for #{seconds_active(state.active_since, now)} seconds with usage: #{state.usage}")
        %{state | previous_usage: event["current_energy_usage"], active_since: nil, usage: 0}
      detection_active?(state) && watercooker_off?(energy_difference) && !active_long_enough?(state.active_since, now) ->
        %{state | previous_usage: event["current_energy_usage"], active_since: nil, usage: 0}
      true ->
        %{state | previous_usage: event["current_energy_usage"]}
    end
  end

  defp watercooker_on?(energy_difference), do: energy_difference > 2 && energy_difference < 2.5
  defp watercooker_off?(energy_difference), do: energy_difference < -2 && energy_difference > -2.5

  defp detection_inactive?(state), do: state.active_since == nil
  defp detection_active?(state), do: state.active_since != nil

  defp seconds_active(start_time, end_time), do: Timex.diff(end_time, start_time, :seconds)
  defp active_long_enough?(start_time, end_time) do
    seconds = seconds_active(start_time, end_time)
    seconds > 1.5 * 60 && seconds < 4 * 60
  end

  defp in_timezone(time) do
    time
    |> Timex.Timezone.convert("Europe/Amsterdam")
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end
end
