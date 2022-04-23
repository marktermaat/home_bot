defmodule HomeLight.Holiday.Scheduler do
  @base_start_time ~T[20:00:00]
  @base_end_time ~T[23:00:00]

  def create_schedule do
    {@base_start_time, @base_end_time}
  end

  def check_schedule({start_time, end_time}) do
    time = current_time()

    cond do
      is_after?(time, start_time) && is_before?(time, end_time) -> :turn_on
      is_after?(time, end_time) -> :turn_off
      true -> :do_nothing
    end
  end

  def refresh_schedule(schedule = {start_time, end_time}) do
    time = current_time()

    cond do
      is_after?(time, end_time) -> create_schedule()
      is_after?(time, start_time) -> {nil, end_time}
      true -> schedule
    end
  end

  defp current_time() do
    {_datepart, timepart} =
      Timex.now("Europe/Amsterdam")
      |> Timex.to_erl()

    Time.from_erl!(timepart)
  end

  defp is_before?(time1, time2) do
    time1 != nil &&
      time2 != nil &&
      Time.compare(time1, time2) == :lt
  end

  defp is_after?(time1, time2) do
    time1 != nil &&
      time2 != nil &&
      Time.compare(time1, time2) == :gt
  end
end
