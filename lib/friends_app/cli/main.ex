defmodule FriendsApp.CLI.Main do
    alias Mix.Shell.IO, as: Shell

    def start_app do
      Shell.cmd("clear")
      welcome_message()
      Shell.prompt("Pressione enter para continuar.")
      starts_menu_choice()
    end

    defp welcome_message do
      Shell.info("============ FriendsApp ============")
      Shell.info("Seja bem vindo a sua agenda pessoal.")
      Shell.info("====================================")
    end

    defp starts_menu_choice, do: FriendsApp.CLI.Menu.Choice.start()
end
