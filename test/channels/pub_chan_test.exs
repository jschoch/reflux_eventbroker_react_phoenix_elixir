defmodule PubChanTest do
  use ExUnit.Case
  import Phoenix.ChannelTest
  @endpoint RefluxEventbrokerReactPhoenixElixir.Endpoint
  test "join works" do
    #{:ok, _, socket} = subscribe_and_join(PubChannel, "all", %{"id" => 3})
    auth = %{pass: "the magic word",user: "me"}
    {res,thing,socket} = subscribe_and_join(PubChannel, "all", auth)
    assert res == :ok
    #assert thing == :foo
  end
  test "push works" do
    
    auth = %{pass: "the magic word",user: "me"}
    {res,thing,socket} = subscribe_and_join(PubChannel, "all",auth)
    assert res == :ok
    assert thing == "welcome"
    msg = %{"text" => "hello", "user" => "me"}
    push socket, "msg",msg
    ref = push socket, "ping",%{"ping" => 1}
    IO.puts "ref: " <> inspect ref
    assert_reply ref, :ok, %{msg: :pong}
  end
  test " login updates agent and broadcasts" do
    auth = %{pass: "the magic word",user: "me"}
    {res,thing,socket} = subscribe_and_join(PubChannel, "all",auth)
    map = LogAgent.get
    assert map.user_count == 1
    auth2 = %{pass: "the magic word",user: "me2"}
    {res,thing,socket2} = subscribe_and_join(PubChannel, "all",auth2)
    assert_broadcast "status_users",%{user_count: _}
  end
end
