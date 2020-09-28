defmodule Mix.Tasks.Start do
  use Mix.Task

  @shortdoc "start [Friends App]"
  def run(_), do: FriendsApp.init()
end
