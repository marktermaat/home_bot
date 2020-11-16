import Config

config :nostrum, token: "FILL_IN"

config :home_bot,
  google_maps_key: "FILL IN",
  home_address: "FILL IN",
  work_address: "FILL IN"

import_config "#{Mix.env()}.exs"
import_config "#{Mix.env()}.secret.exs"
