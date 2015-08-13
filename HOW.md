#  Phoenix Sockets and react.js components via reflux.js

## In this post I will describe how to wire up some server state to our react components

The [first post](http://blog.brng.us/2015-08-04-using-reflux-to-broker-events-with-react-and-phoenix.html) described how to use react.js and reflux to coordinate react components.  This post will describe how to wire in server state through phoenix sockets.

The great thing about this approach is that you largely remove the drudgery of creating a REST CRUD api, and just send json down to your javascript as events.  The dataflow is in one direction, which simplifies our design.

To demonstrate this we will be adding a few key components.  The first will be an Elixir Agent to hold our state.  The second will be to integrate our Reflux store with Phoenix sockets.  We will track clicks to our buttons, and who's using the system.

[this graph](http://brng.us/dagre.html?graph=%2F*%20Example%20*%2F%0Adigraph%20%7B%0A%20%20%20%20%2F*%20Note%3A%20HTML%20labels%20do%20not%20work%20in%20IE%2C%20which%20lacks%20support%20for%20%3CforeignObject%3E%20tags.%20*%2F%0A%0A%20%20%20%20node%20%5Brx%3D5%20ry%3D5%20labelStyle%3D%22font%3A%20300%2014px%20%27Helvetica%20Neue%27%2C%20Helvetica%22%5D%0A%20%20%20%20edge%20%5Blabelpos%3Dc%20labelStyle%3D%22font%3A%20300%2014px%20%27Helvetica%20Neue%27%2C%20Helvetica%3Bbackground-color%3Awhite%22%5D%0A%20%20%20%20U1%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3EUser%201%3C%2Fspan%3E%22%5D%3B%0AU2%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3EUser%202%3C%2Fspan%3E%22%5D%3B%0A%2F%2FU3%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3EUser%203%3C%2Fspan%3E%22%5D%3B%0AL%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3ELogAgent%3C%2Fspan%3E%22%5D%3B%0AS%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3ETheStore%3C%2Fspan%3E%22%5D%3B%0AS2%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3ETheStore%3C%2Fspan%3E%22%5D%3B%0AP%20%5BlabelType%3D%22html%22%20label%3D%22%3Cspan%20style%3D%27font-size%3A14px%27%3EPhoenix%3C%2Fspan%3E%22%5D%3B%20%20%20%0A%0AU2%20-%3E%20P%20%5Blabel%3D%22click%20%22%20labelType%3D%22html%22%5D%3B%0AP-%3E%20S%20%5Blabel%3D%22update_user%22%20labelType%3D%22html%22%20style%3D%22stroke%3A%20%23f66%3B%20stroke-width%3A%203px%3B%20stroke-dasharray%3A%205%2C%205%3B%22%5D%3B%0AP-%3E%20S2%20%5Blabel%3D%22update_user%22%20labelType%3D%22html%22%20style%3D%22stroke%3A%20%23f66%3B%20stroke-width%3A%203px%3B%20stroke-dasharray%3A%205%2C%205%3B%22%5D%3B%0AS2%20-%3E%20U2%20%5Blabel%3D%22update%20UI%22%20labelType%3D%22html%22%20style%3D%22stroke%3A%20%23f66%3B%20stroke-width%3A%203px%3B%20stroke-dasharray%3A%205%2C%205%3B%22%5D%3B%0AS-%3E%20U1%20%5Blabel%3D%22update%20UI%22%20labelType%3D%22html%22%20style%3D%22stroke%3A%20%23f66%3B%20stroke-width%3A%203px%3B%20stroke-dasharray%3A%205%2C%205%3B%22%5D%3B%0AL%20-%3E%20P%20%5Blabel%3D%22broadcast%22%20labelType%3D%22html%22%20style%3D%22stroke%3A%20%23f66%3B%20stroke-width%3A%203px%3B%20stroke-dasharray%3A%205%2C%205%3B%22%5D%3B%0A%0AP%20-%3E%20L%20%5Blabel%3D%22Hit%22%20labelType%3D%22html%22%5D%3B%0A%7D%0A%20%20) shows the basic flow of data.

### Let's look at how to hold our server state.

An elixir agent is essentially a server process that will hold state in memory.  It can [leverage supervision, and be run as an application](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html).  The Elixir docs for Agent can be found [here](http://elixir-lang.org/docs/v1.0/elixir/Agent.html).  Our agent will provide functions to:

* Register a user login
* Register a user logout
* Register a user click
* Retrieve the current user_count
* Retrieve the current state
* Start and Stop

I also subbed out broadcasting and messages, which we will ignore for now.

> [lib/agent.ex](https://github.com/jschoch/reflux_eventbroker_react_phoenix_elixir/blob/e43834e3129cd8538fef083e642f9db5da9bb0db/lib/agent.ex)

### setup state: def start_link
our start_link function initializes our state.  In this case it is simply a map with default attributes: an empty list for users, a zero user count, an empty list for messages, and a zero count for hits.

We simply pass a function which returns the map, and a name, which gets compiled to the module name Elixir.LogAgent or in Elixir just LogAgent.
```elixir
def start_link do
    map = %{users: [],user_count: 0, msgs: [],hits: 0} 
    Agent.start_link(fn -> map end, name: __MODULE__)
  end
```

### get state: def get

Def simply calls Agent.get with our module name, and it uses function shorthand, or [partial application](http://elixir-lang.org/crash-course.html#partials-in-elixir) to return the state.  

``` elixir
  def get_user_count do
    Agent.get(__MODULE__,&Map.fetch(&1,:user_count))
  end
```

We could also write this more verbose 

```elixir
  def get do
    Agent.get(__MODULE__,fn(state) -> 
      # last arg is returned
      state
    end)
  end
```

### register a login: def login(user)

This grabs a user and puts it into our state map.  One flaw to be fixed here is the fact that we don't check to see if the user is already logged in. I

If you are unfamiliar with Elixir or Erlang, the syntax for adding a user to our list may be confusing.  This is called a "cons cell", and it allows you to reference a list as a head and a tail.  When used on the left side of "=" it interpolates the first element of a list into the varriable on the left of the "|", and the rest of the list to the right.

```elixir
[head|tail] = [1,2,3,4,5]
```
head is now 1, and tail is now [2,3,4,5].  this is because "=" is not an assignment operator like most languages, but a pattern match.  

When used on the right side of "=", or bare you prepend head to your list.

```elixir
# bare
iex(7)> element = 1
1
iex(8)> list = [2,3,4]
[2, 3, 4]
iex(9)> [element|list]
[1, 2, 3, 4]

# right side of "="
iex(10)> list = [1|[1,2,3]]
[1, 1, 2, 3]
```

Back to our Agent...

```elixir
  def login(user) do
    # get the current state
    s = get()
    # increment our user counter
    new_state = Map.put(s,:user_count,s.user_count + 1)
    IO.puts inspect new_state
    # add our user to our users list
    new_state = Map.put(new_state,:users,[user|new_state.users])
    IO.puts inspect new_state
    # store the update
    Agent.update(__MODULE__,fn state -> new_state end)
    # stub to broadcast a change event
    bcast
  end
```

The rest of the agent is pretty straight forward if you understand the partial application syntax.

### Setup phoenix channels and sockets

Step one here is to look at our endpoint, and ensure we have our sockets mapped correctly.

> [lib/reflux_eventbroker_react_phoenix_elixir/endpoint.ex](https://github.com/jschoch/reflux_eventbroker_react_phoenix_elixir/blob/e24436af6e55cd50a177c775a62b71c5937780f0/lib/reflux_eventbroker_react_phoenix_elixir/endpoint.ex)

```elixir
defmodule RefluxEventbrokerReactPhoenixElixir.Endpoint do
  use Phoenix.Endpoint, otp_app: :reflux_eventbroker_react_phoenix_elixir

  # commenting this out caused me all kinds of problems.  Seems to be some leftover assumptions this exists.
  socket "/socket", RefluxEventbrokerReactPhoenixElixir.UserSocket
  
  # this plumbs our socket path to our Socket functions in web/channels/pub_chat_socket.ex
  socket "/status",Reflux.PubChatSocket
  
# SNIP
```

> [web/channels/pub_chat_socket.ex](https://github.com/jschoch/reflux_eventbroker_react_phoenix_elixir/blob/e24436af6e55cd50a177c775a62b71c5937780f0/web/channels/pub_chat_socket.ex)

Phoenix web sockets break things into sockets and channels.  Sockets allow you to manage connections and authenticate a particular websocket path.  They also allow you to manage the transport.

``` elixir
defmodule Reflux.PubChatSocket do
  require Logger
  use Phoenix.Socket
  
  # Defines our channel name, and what Elixir module will be used to control it, PubChannel in this case
  
  channel "all",PubChannel 
  
  # Defines the transport, and if we need to check the host origin.  Check origin is useful if you want to limit access to your sockets to certain hosts
  
  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false

  # connect parses our connection parameters from our client.  using phoenix.js this is socket.connect(params);
  # we also use Phoenix.Socket.assign/3 to embed our user and pass into the socket struct, which gets passed along to out channel.
  
  def connect(params, socket) do
    Logger.info "PARAMS: \n " <> inspect params
    socket = assign(socket, :user, params["user"])
    socket = assign(socket, :pass, params["pass"])
    {:ok,socket}
  end

  # id allows us to broadcast to all users with a particular id.  I'm not using this in this revision.
  
  def id(socket) do
    Logger.info("id called" <> inspect socket, pretty: true)
   "users_socket:#{socket.assigns.user}"
  end
end
```

So now we have our channel "all" mapped to our channel logic.

> [web/channels/pub_channel.ex](https://github.com/jschoch/reflux_eventbroker_react_phoenix_elixir/blob/e43834e3129cd8538fef083e642f9db5da9bb0db/web/channels/pub_channel.ex)

* join/3 : manages client join requests
* handle_info/2 : manages our state update broadcasts
* handle_in/3 : manages any messages sent to the channel after join has completed successfully 
* terminate/2 : manages when a websocket connection is no longer active

Channels use the [behaviour pattern](http://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours).  Behaviours allow us structure and composition.  They are most heavily used in OTP patterns like GenServer.  Behaviours generally lean heavily on pattern matching in function definition, which is worth of discussion for folks new to Elixir.

Take the following definitions
```elixir
defmodule Foo do
    #1
    def bar(:atom) do
        "got an atom"
    end
    #2
    def bar({a,b}) do
        "got a 2 tuple with varriables a and b assigned the arg's tuple values"
    end
    #3
    def bar(%{foo: foo} = arg) do
        "got a map with a key of :foo, interpolated into the varriable 'foo', and the full map assigned to 'arg'"
    end
    #4
    def bar(%{"foo" => foo} = arg) do
        "foo key was a binary"
    end
    #5
    def bar(any) do
        any
    end
end
```
Elixir will take any call to Foo.bar(arg) and try to see if the argument fits a definition.  This works top to bottom.  The last case #5 will match any call to Foo.bar/1.  Having a catch all can be useful in debugging to detect and crash when you have unexpected input.  Example #1 will only match for Foo.bar(:atom).  Example #2 will only match a 2 element tuple.  Examaple #3 is much more interesting and powerful.

Elixir map pattern matching allows you to look inside the argument and use different function definitions based on the keys of the map.  In this case we will only match #3 if we use a map as an argument, and that map has a key of :foo.  If we want access to the rest of the map we can use the arg varriable.  We can pass any map containing the key :foo %{foo: 1,bar: 2} will match, but %{"foo" => 1} will match #4 because the key is a binary (string).  When you are serializing data to javascript it is best to use binaries as strings.  Binaries also have very powerful pattern matching capabilites you may wan to explore.

For phoenix channels we need join/3, and handle_in at a minimum.
