ExUnit.configure(exclude: [pending: true], formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
ExUnit.start()
