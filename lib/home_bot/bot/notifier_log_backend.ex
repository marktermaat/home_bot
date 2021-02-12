defmodule HomeBot.Bot.NotifierLogBackend do
  @moduledoc """
  Notifier backend
  """
  def init({__MODULE__, name}) do
    {:ok, %{name: name, level: :error}}
  end

  def handle_call({:configure, opts}, %{name: name}=state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({level, _group_leader, {Logger, message, _timestamp, _metadata}}, %{level: min_level}=state) do
    if right_log_level?(min_level, level) do
      [error_message | stack_trace] = String.split(to_string(message), "\n")
      HomeBot.Bot.notify_users("[**#{Atom.to_string(level)}**] [#{Application.get_env(:home_bot, :env)}] #{error_message}\n#{stack_trace}")
    end
    {:ok, state}
  end

  defp right_log_level?(nil, _level), do: true
  defp right_log_level?(min_level, level) do
    Logger.compare_levels(level, min_level) != :lt
  end

  defp configure(_name, [level: new_level], state) do
    Map.merge(state, %{level: new_level})
  end

  defp configure(_name, _opts, state), do: state
end
