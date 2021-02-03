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

### Password
To generate a password, open an iex shell:
```elixir
Argon2.Base.hash_password(to_string("password"),Argon2.gen_salt(), [{:argon2_type, 2}])
```