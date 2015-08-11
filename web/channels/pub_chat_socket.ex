defmodule Reflux.PubChatSocket do
  require Logger
  use Phoenix.Socket
  channel "all",PubChannel 
  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  #  To deny connection, return `:error`.
  def connect(params, socket) do
    Logger.info "PARAMS: \n " <> inspect params
    socket = assign(socket, :user, params["user"])
    socket = assign(socket, :pass, params["pass"])
    {:ok,socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     RefluxEventbrokerReactPhoenixElixir.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
  def id_defunct(socket) do
    Logger.info("id called" <> inspect socket, pretty: true)
   "users_socket:#{socket.assigns.user}"
  end
end
