use Mix.Config

config :mix_test_watch,
  clear: true,
  tasks: [
    "coveralls",
    "dialyzer",
    "credo"
  ]
