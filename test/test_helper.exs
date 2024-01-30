ExUnit.configure(exclude: [pending: true], formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
ExUnit.start()
Application.put_env(:elixir, :time_zone_database, Tzdata.TimeZoneDatabase)
Code.require_file("test/support/datetime_sigil.ex")
