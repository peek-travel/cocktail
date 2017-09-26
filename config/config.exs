use Mix.Config

config :logger,
  backends: [],
  compile_time_purge_level: :info

if Mix.env == :dev do
  config :mix_test_watch,
    clear: true,
    tasks: [
      "coveralls",
      "dialyzer",
      "credo"
    ]
end

if Mix.env == :debug do
  config :logger,
    backends: [:console],
    compile_time_purge_level: :debug

  config :logger, :console,
    format: "$time $metadata[$level] $levelpad$message\n"
end
