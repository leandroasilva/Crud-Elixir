defmodule FriendsApp.DB.CSV do
  alias Mix.Shell.IO, as: Shell
  alias NimbleCSV.RFC4180, as: CSVParse
  alias FriendsApp.CLI.Menu
  alias FriendsApp.CLI.Menu.Choice
  alias FriendsApp.CLI.Friend

  def perform(chosen_menu_item) do
    case chosen_menu_item do
      %Menu{ id: :create, label: _} -> create()
      %Menu{ id: :read, label: _} -> read()
      %Menu{ id: :update, label: _} -> update()
      %Menu{ id: :delete, label: _} -> delete()
    end
    Choice.start()
  end

  defp update do
    Shell.cmd("clear")
    prompt_message("Digite o email do Contato a ser atualizado?: ")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_update()
    |> do_update()
  end

  defp do_update(friend) do
    Shell.cmd("clear")
    Shell.info("Agora voce irá digitar os novos dados deste amigo..")

    update_friend = collect_data()

    get_struct_list_from_csv()
    |> delete_friend_from_csv(friend)
    |> friend_list_to_csv()
    |> prepare_list_to_save
    |> save_csv_file()

    update_friend
    |> transform_on_wrapped
    |> prepare_list_to_save
    |> save_csv_file([:append])

    Shell.info("OK, o amigo atualizado com sucesso")
    Shell.prompt("Pressione ENTER para continuar...")
  end

  defp confirm_update(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos ....")

    show_friend(friend)
    case Shell.yes?("Deseja realmente atualizar este amigo da lista") do
      true -> friend
      false -> :error
    end
  end

  defp delete do
    Shell.cmd("clear")

    prompt_message("Digite o email do Contato a ser apagado?: ")
    |> search_friend_by_email()
    |> check_friend_found()
    |> confirm_delete()
    |> delete_and_save()
  end

  defp search_friend_by_email(email) do
    get_struct_list_from_csv()
    |> Enum.find(:not_found, fn list ->
      list.email == email
    end)
  end

  defp check_friend_found(friend) do
    case friend do
      :not_found ->
        Shell.cmd("clear")
        Shell.error("Amigo nao encontrado")
        Shell.prompt("Pressione entrer para continuar")
        Choice.start()
      _ -> friend
    end
  end

  defp confirm_delete(friend) do
    Shell.cmd("clear")
    Shell.info("Encontramos ....")

    show_friend(friend)
    case Shell.yes?("Deseja realmente apagar este amigo da lista") do
      true -> friend
      false -> :error
    end
  end

  defp show_friend(friend) do
    friend
    |> Scribe.print(data: [{"Nome", :name}, {"E-Mail", :email}, {"Telefone", :phone}])
  end

  defp delete_and_save(friend) do
    case friend do
      :error ->
        Shell.info("OK, o amigo nao será excluido")
        Shell.prompt("Pressione ENTER para continuar...")
      _ ->
        get_struct_list_from_csv()
        |> delete_friend_from_csv(friend)
        |> friend_list_to_csv()
        |> prepare_list_to_save
        |> save_csv_file

        Shell.info("OK, o amigo excluido com sucesso.")
        Shell.prompt("Pressione ENTER para continuar...")
    end
  end

  defp delete_friend_from_csv(list, friend) do
    list
    |> Enum.reject(fn elem -> elem.email == friend.email end)
  end

  defp friend_list_to_csv(list) do
    list
    |> Enum.map(fn item ->
      [item.email, item.name, item.phone]
    end)
  end

  defp create do
    collect_data()
    |> transform_on_wrapped
    |> prepare_list_to_save
    |> save_csv_file([:append])
  end

  defp prepare_list_to_save(data) do
    data
    |> CSVParse.dump_to_iodata
  end

  defp transform_on_wrapped(data) do
    data
    |> Map.from_struct
    |> Map.values
    |> wrap_in_list
  end

  defp collect_data do
    Shell.cmd("clear")
    %Friend{
      name: prompt_message("Digite o nome: "),
      email: prompt_message("Digite o email: "),
      phone: prompt_message("Digite o telefone: ")
    }
  end

  defp prompt_message(message) do
    Shell.prompt(message)
    |> String.trim()
  end

  defp wrap_in_list(list) do
    [list]
  end

  defp save_csv_file(data, mode \\ []) do
    File.write!(Application.fetch_env!(:friends_app, :csv_file_path), data, mode)
  end

  defp parse_csv_file_to_list(csv_file) do
    csv_file
    |> CSVParse.parse_string(headers: false)
  end

  defp read_csv_file do
    File.read!(Application.fetch_env!(:friends_app, :csv_file_path))
    |> parse_csv_file_to_list()
  end

  defp csv_list_to_friends_strunc_list(friends_list) do
    Enum.map(friends_list, fn [email, name, phone] ->
      %Friend{name: name, email: email, phone: phone}
    end)
  end

  defp get_struct_list_from_csv do
    read_csv_file()
    |> csv_list_to_friends_strunc_list
  end

  defp read() do
    get_struct_list_from_csv()
    |> show_friends
  end

  defp show_friends(struct_friends) do
    struct_friends
    |> Scribe.console(data: [{"Nome", :name}, {"E-Mail", :email}, {"Telefone", :phone}])
  end
end
