defmodule HomeBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :home_bot,
      version: get_and_update_version!(),
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssh, :phoenix_ecto],
      mod: {HomeBot, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4.6", runtime: Mix.env() != :test},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:logger_file_backend, "~> 0.0.11"},
      {:quantum, git: "https://github.com/quantum-elixir/quantum-core.git"},
      {:instream, "~> 1.0"},
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.6"},
      {:ecto_sqlite3, "~> 0.5.5"},
      {:cowlib, "~> 2.9", override: true},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.4"},
      {:bcrypt_elixir, "~> 2.3"},
      {:credo, "~> 1.5", only: :dev},
      {:contex, git: "https://github.com/mindok/contex.git"},
      {:timex, "~> 3.6"},
      {:gen_stage, "~> 1.1"}
    ]
  end

  defp get_and_update_version! do
    case System.cmd("git", ~w[rev-list --count main]) do
      {version, 0} -> create_version_from_git_commits(version)
      _ -> read_version_from_file()
    end
  end

  defp create_version_from_git_commits(number_of_commits) do
    version_number = String.trim(number_of_commits)

    version = "0.#{version_number}.0"
      |> Version.parse!()
      |> to_string()

    :ok = File.write(".version", version)

    version
  end

  defp read_version_from_file do
    case File.read(".version") do
      {:ok, version} -> version
      _ -> "0.0.0"
    end
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
