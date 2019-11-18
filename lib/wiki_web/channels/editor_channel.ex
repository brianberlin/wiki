defmodule WikiWeb.EditorChannel do
  use WikiWeb, :channel

  alias Wiki.{Editor, EditorRegistry, EditorSupervisor}
  def join("editor:" <> id, _, socket) when is_binary(id) do
    case Registry.lookup(EditorRegistry, id) do
      [{_pid, nil}] ->
        nil
      _ ->
        {:ok, _pid} = DynamicSupervisor.start_child(EditorSupervisor, {Editor, name: via_tuple(id)})
    end
    :ok = Phoenix.PubSub.subscribe(Wiki.PubSub, id)
    socket = assign_editor(socket, id)
    %{assigns: %{editor: %{content: content}}} = socket

    {:ok, Map.from_struct(content), socket}
  end

  def handle_in("update", %{"delta" => delta}, %{assigns: %{id: id}} = socket) do
    GenServer.cast(via_tuple(id), {:update, AtomicMap.convert(delta, %{safe: false})})
    broadcast_from(socket, "update", %{delta: delta})

    {:noreply, assign_editor(socket)}
  end

  def handle_in("new_state", _, %{assigns: %{editor: %{content: content}}} = socket) do
    push(socket, "new_state", %{content: content})
    {:noreply, assign_editor(socket)}
  end

  defp assign_editor(socket, id) do
    socket
    |> assign(:id, id)
    |> assign_editor()
  end

  defp assign_editor(%{assigns: %{id: id}} = socket) do
    editor = GenServer.call(via_tuple(id), :editor)

    assign(socket, :editor, editor)
  end

  def via_tuple(id) do
    {:via, Registry, {EditorRegistry, id}}
  end
end
