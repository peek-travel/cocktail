ExUnit.configure(exclude: [pending: true])
ExUnit.start()

{:ok, files} = File.ls("./test/support")

Enum.each(files, fn(file) ->
  Code.require_file( "test/support/#{file}")
end)
