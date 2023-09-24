ExUnit.configure(exclude: [pending: true], formatters: [ExUnit.CLIFormatter, ExUnitNotifier])
ExUnit.start()

Code.require_file("test/support/datetime_sigil.ex")
