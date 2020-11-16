defmodule HomeBot.Bot.CommandHandler do
  @callback handle(atom(), String.t()) :: :ok
end
