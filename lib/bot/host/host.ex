defmodule HomeBot.Bot.Host do
  @ssh_host Application.fetch_env!(:home_bot, :ssh_host)
  @ssh_username Application.fetch_env!(:home_bot, :ssh_username)
  @ssh_password Application.fetch_env!(:home_bot, :ssh_password)

  def execute(command) do
    :ssh.start()

    {:ok, conn} =
      :ssh.connect(to_charlist(@ssh_host), 22,
        user: to_charlist(@ssh_username),
        password: to_charlist(@ssh_password),
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
end
