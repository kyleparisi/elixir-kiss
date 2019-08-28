defmodule MyApp.App do
  use Application

  def start(_type, _args) do
    topologies = [
      gossip_example: [
        strategy: Elixir.Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "230.1.1.251",
          multicast_ttl: 1,
          secret: "somepassword"
        ]
      ]
    ]
    children = [
      {Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]},
      # ..other children..

    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end

defmodule MyApp.Supervisor do
  @moduledoc """
  This is the supervisor for the worker processes you wish to distribute
  across the cluster, Swarm is primarily designed around the use case
  where you are dynamically creating many workers in response to events. It
  works with other use cases as well, but that's the ideal use case.
  """
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(MyApp.Worker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Registers a new worker, and creates the worker process
  """
  def register(worker_name) do
    import Supervisor.Spec
    {:ok, _pid} = Supervisor.start_child(__MODULE__, worker(MyApp.Worker, [worker_name]))
  end
end

defmodule MyApp.Worker do
  @moduledoc """
  This is the worker process, in this case, it simply posts on a
  random recurring interval to stdout.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, [name])
  end

  def init([name]) do
    {:ok, {name, :rand.uniform(5_000)}, 0}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, {name, delay}) do
    {:reply, {:resume, delay}, {name, delay}}
  end
  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, delay}, {name, _}) do
    {:noreply, {name, delay}}
  end
  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _delay}, state) do
    {:noreply, state}
  end

  def handle_info(:timeout, {name, delay}) do
    IO.puts "#{inspect name} says hi!"
    Process.send_after(self(), :timeout, delay)
    {:noreply, {name, delay}}
  end
  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end

defmodule MyApp.ExampleUsage do

  @doc """
  Starts worker and registers name in the cluster, then joins the process
  to the `:foo` group
  """
  def start_worker(name) do
    # the following works but is not
    # Swarm.register_name("abc", MyApp.Worker, :start_link, ["abc"])
    {:ok, pid} = Swarm.register_name(name, MyApp.Supervisor, :register, [name])
    Swarm.join(:foo, pid)
  end

  @doc """
  Gets the pid of the worker with the given name
  """
  def get_worker(name), do: Swarm.whereis_name(name)

  @doc """
  Gets all of the pids that are members of the `:foo` group
  """
  def get_foos(), do: Swarm.members(:foo)

  @doc """
  Call some worker by name
  """
  def call_worker(name, msg), do: GenServer.call({:via, :swarm, name}, msg)

  @doc """
  Cast to some worker by name
  """
  def cast_worker(name, msg), do: GenServer.cast({:via, :swarm, name}, msg)

  @doc """
  Publish a message to all members of group `:foo`
  """
  def publish_foos(msg), do: Swarm.publish(:foo, msg)

  @doc """
  Call all members of group `:foo` and collect the results,
  any failures or nil values are filtered out of the result list
  """
  def call_foos(msg), do: Swarm.multi_call(:foo, msg)

end