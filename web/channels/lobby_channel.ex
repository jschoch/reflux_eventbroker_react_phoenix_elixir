defmodule LobbyChannel do
  require Logger
  use Phoenix.Channel
  #def join("all",%{pass: "the magic word"} = payload,socket) do
  def join("rooms:lobby",payload,socket) do
    Logger.info "Lobby: Payload: #{inspect payload}" 
    {:ok,socket}
  end
end
