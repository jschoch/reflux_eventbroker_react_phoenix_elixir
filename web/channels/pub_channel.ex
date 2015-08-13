defmodule PubChannel do
  require Logger
  use Phoenix.Channel
  #def join("all",%{pass: "the magic word"} = payload,socket) do
  def join("all",p,socket) do
    user = socket.assigns.user
    #socket = Phoenix.Socket.assign(socket, :user, socket.assigns.user)
    LogAgent.login(user)
    Logger.info "User #{user} logged in: payload: #{inspect p}"
    # we can't broadcast from here so we call to handle_info
    send self,:status_update
    {:ok,"welcome",socket}
  end
  
  def join(any,s,socket) do
    Logger.error("unkown channel: #{inspect any} for assigns #{inspect socket.assigns}") 
    {:error, %{reason: "unauthorized"}}
  end
  def handle_info(:status_update,socket) do
    Logger.info "handle_info :status_update"
    broadcast! socket, "status_users", LogAgent.get
    {:noreply, socket}
  end
  def handle_in("msg",%{"user" => user} = payload,socket) do
    Logger.info "payload: " <> inspect payload
    {:noreply,socket}
  end
  def handle_in("status_users",stuff,socket) do
    Logger.info "status_users: #{inspect stuff}"
    {:noreply,socket}
  end
  def handle_in("ping",%{"ping" =>  _},socket) do
    Logger.info "PING from: " <> inspect socket.assigns.user, pretty: true
    {:reply,{:ok,%{msg: :pong}}, socket}
  end
  def handle_in("hit",p,socket) do
    Logger.info "Hit from #{socket.assigns.user}"
    LogAgent.hit
    send self,:status_update
    {:noreply,socket}
  end
  def handle_in(any_event,any_payload,socket) do
    Logger.error inspect {any_event,any_payload}
    {:stop,{:error, %{reason: "unknown event"}},socket}
  end
  def terminate(reason,socket) do
    if socket.assigns.user != nil, do: LogAgent.logout(socket.assigns.user)
    Logger.info("terminated: #{inspect socket.assigns}")
    :timer.sleep(50)
    send self,:status_update
    :ok
  end

end
