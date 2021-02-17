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

# Password
To generate a password, open an iex shell:
```elixir
Bcrypt.hash_pwd_salt("password")
```

When putting this password in the docker-compose.yml file, make sure to add a $ for every existing $ sign.

# Ideas
- A graph that shows gas usage vs temperature of the last period
- A graph that shows average gas usage per temperature celcius (temperature on x-axis)
- A graph that shows average gas usage per temperature celcius, 1 line per year (to compare years)
- A graph that normalizes gas usage against temperature (gas usage per day / temperature), showing that for a given period, or perhaps also with 1 line per year
- A page to show energy usage for a given period
- A page to compare energy usage of 2 given periods
