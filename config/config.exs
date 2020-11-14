import Config

config :nostrum,
  token: "FILL_IN"

import_config "#{Mix.env()}.exs"
import_config "#{Mix.env()}.secret.exs"
