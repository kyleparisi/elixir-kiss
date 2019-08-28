defmodule Game do
  use GenServer

  def init(game_id) do
    {:ok, %{game_id: game_id}}
  end

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: {:global, "game:#{game_id}"})
  end

  def add_player(pid, player_name) do
    GenServer.call(pid, {:add_player, player_name})
  end

  def handle_call({:add_player, player_name}, _from, %{game_id: game_id} = state) do
    # Now we replace this with supervised management
    start_status = PlayerDynamicSupervisor.add_player(player_name, game_id)
    {:reply, start_status, state}
  end
end

defmodule PlayerDynamicSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Start a Player process and add it to supervision
  def add_player(player_name, game_id) do
    # Note that start_child now directly takes in a child_spec.
    child_spec = {Player, {player_name, game_id}}
    # Equivalent to:
    # child_spec = Player.child_spec({player_name, game_id})
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  # Terminate a Player process and remove it from supervision
  def remove_player(player_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, player_pid)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Nice utility method to check which processes are under supervision
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end

defmodule Player do
  use GenServer

  def init({player_name, game_id}) do
    {:ok, %{name: player_name, game_id: game_id}}
  end

  def start_link({player_name, game_id}) do
    GenServer.start_link(
      __MODULE__,
      {player_name, game_id},
      name: {:global, "player:#{player_name}"}
    )
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, {:ok, state}, state}
  end
end
