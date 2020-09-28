defmodule Mix.Tasks.Utils.AddFakeFriends do
  alias NimbleCSV.RFC4180, as: CSVParse
  use Mix.Task

  @shortdoc "fake-friends [Adiciona fake amigos no DB]"
  def run(_) do
    Faker.start()

    create_friends([], 50)
    |> CSVParse.dump_to_iodata
    |> save_csv_file
  end

  defp create_friends(list, qtde) when qtde <= 1 do
    list ++ [random_list_friend()]
  end

  defp create_friends(list, qtde) do
    list ++ [random_list_friend()] ++ create_friends(list, qtde - 1)
  end

  defp random_list_friend do
    [ Faker.Internet.email(), Faker.Person.PtBr.name(), Faker.Phone.EnUs.phone() ]
  end

  defp save_csv_file(data) do
    File.write!("#{File.cwd!}/friends.csv", data, [:append])
  end
end
