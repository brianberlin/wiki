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
    %{assigns: %{editor: %{lines: lines}}} = socket

    {:ok, lines, socket}
  end

  def handle_in("update", %{"content" => content, "line_number" => line_number}, %{assigns: %{id: id}} = socket) do
    GenServer.cast(via_tuple(id), {:update, line_number, content})
    broadcast_from(socket, "line_change", %{line_number: line_number, content: content})

    {:noreply, assign_editor(socket)}
  end

  def handle_in("new_state", _, %{assigns: %{editor: %{lines: lines}}} = socket) do
    push(socket, "new_state", %{lines: lines})
    {:noreply, assign_editor(socket)}
  end

  def handle_info(:md5_check, socket) do
    editor = GenServer.call(via_tuple(socket.assigns.id), :editor)

    broadcast(socket, "md5_check", %{md5: editor.md5})
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
