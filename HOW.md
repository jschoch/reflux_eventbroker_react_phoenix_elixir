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

This grabs a user and puts it into our state map.  One flaw to be fixed here is the fact that we don't check to see if the user is already logged in. 

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

