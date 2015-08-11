defmodule LogAgent do
  @doc "starts the agent with a starter Map"
  def start_link do
    map = %{users: [],user_count: 0, msgs: []} 
    Agent.start_link(fn -> map end, name: __MODULE__)
  end
  
  @doc "registers a user logging in"
  def login(user) do
    s = get
    new_state = Map.put(s,:user_count,s.user_count + 1)
    IO.puts inspect new_state
    new_state = Map.put(new_state,:users,[user|new_state.users])
    IO.puts inspect new_state
    Agent.update(__MODULE__,fn state -> new_state end)
    bcast
  end

  @doc "registers a user logging out"
  def logout(user) do
    s = get
    if (user in s.users) do
      new_state = Map.put(s,:user_count,s.user_count - 1)
      IO.puts inspect new_state
      new_state = Map.put(new_state,:users,List.delete(new_state.users,user))
      IO.puts inspect new_state
      Agent.update(__MODULE__,fn old_state -> new_state end)
      bcast
    else 
      IO.puts "can't find #{inspect user} to logout"
    end
  end
  @doc "stops the agent"
  def stop do
    Agent.stop(__MODULE__)
    bcast
  end
  @doc "registers a new message"
  def msg(msg) do
    s = get
    new_state = Map.put(s,:msgs,[msg|s.msgs])
    Agent.update(__MODULE__,fn old_state -> new_state end)
  end
  @doc "gets the state of the agent"
  def get do
    Agent.get(__MODULE__,&(&1))
  end
  def get_user_count do
    Agent.get(__MODULE__,&Map.fetch(&1,:user_count))
  end
  def bcast do
    IO.puts "SOMETHING CHANGED!"
  end
end
