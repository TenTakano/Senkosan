Path.wildcard("test/support/*.exs")
|> Enum.each(&Code.require_file/1)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
