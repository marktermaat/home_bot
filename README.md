# HomeBot

My personal home discord bot.
It's specifically tailored to my server and settings, but feel free to steal ideas or concepts.

# Development
To run the server:
```bash
mix phx.server
```

Code reloading should be enabled by default. To also compile live compile and reload js and css:
```bash
cd assets
npm run watch
```

To connect to my dev DBs, do a port forward:
```bash
ssh -L 8086:localhost:8086 home
ssh -L 5510:localhost:5510 home
```

# Password
To generate a password, open an iex shell:
```elixir
Bcrypt.hash_pwd_salt("password")
```

When putting this password in the docker-compose.yml file, make sure to add a $ for every existing $ sign.

# Ideas
- Add graphs with usage per month
- Add graphs with usage for each month per year (grouped by month)
- Make graphs that are clickable and zoomable
- Show night and day in the hour graphs (using this plugin: https://github.com/chartjs/chartjs-plugin-annotation#box-annotations)
