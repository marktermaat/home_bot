defmodule HomeBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :home_bot,
      version: get_version(),
      elixir: "~> 1.11",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssh],
      mod: {HomeBot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:logger_file_backend, "~> 0.0.11"},
      {:quantum, git: "https://github.com/quantum-elixir/quantum-core.git"},
      {:instream, "~> 1.0"},
      {:phoenix, "~> 1.5"},
      {:cowlib, "~> 2.9", override: true},
      {:plug_cowboy, "~> 2.4"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.4"},
      {:bcrypt_elixir, "~> 2.3"},
      {:credo, "~> 1.5", only: :dev}
    ]
  end

  defp get_version do
    version = case System.cmd("git", ~w[rev-list --count main]) do
      {version, 0} -> version |> String.trim
      _ -> "0"
    end

    "0.#{version}.0"
      |> Version.parse!()
      |> to_string()
  end
end
