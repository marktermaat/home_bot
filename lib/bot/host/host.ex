defmodule HomeBot.Bot.Host do
  def execute(command) do
    :ssh.start()

    IO.puts(@ssh_host)
    IO.puts(@ssh_username)
    IO.puts(@ssh_password)

    {:ok, conn} =
      :ssh.connect(to_charlist(ssh_host()), 22,
        user: to_charlist(ssh_username()),
        password: to_charlist(ssh_password()),
        user_interaction: false,
        silently_accept_hosts: true
      )

    {:ok, chan} = :ssh_connection.session_channel(conn, :infinity)
    :success = :ssh_connection.exec(conn, chan, command, :infinity)

    receive_results()
  end

  def receive_results(results \\ []) do
    receive do
      {:ssh_cm, _, {:data, _, _, data}} -> receive_results(results ++ [data])
      {:ssh_cm, _, {:eof, _}} -> receive_results(results)
      {:ssh_cm, _, {:exit_status, _, _}} -> receive_results(results)
      {:ssh_cm, _, {:closed, _}} -> results
    end
  end

  defp ssh_host() do
    Application.fetch_env!(:home_bot, :ssh_host)
  end

  defp ssh_username() do
    Application.fetch_env!(:home_bot, :ssh_username)
  end

  defp ssh_password() do
    Application.fetch_env!(:home_bot, :ssh_password)
  end
end
