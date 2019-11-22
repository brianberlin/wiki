defmodule WikiWeb.EditorChannel do
  use WikiWeb, :channel
  alias Wiki.{Editor, EditorRegistry, EditorSupervisor}
  alias WikiWeb.Presence

  def join("editor", %{"id" => id}, socket) do
    send(self(), {:after_join, id})
    {:ok, socket}
  end

  def handle_in("update", %{"ops" => ops}, %{assigns: %{id: id, user_id: user_id}} = socket) do
    GenServer.cast(via_tuple(id), {:update, atomize_keys(ops), user_id})

    {:noreply, socket}
  end

  def handle_in("md5", md5, socket) do
    if editor_hash(socket.assigns.editor) !== md5 do
      push(socket, "clean", socket.assigns.editor.content)
    end

    {:noreply, socket}
  end

  def handle_info({:after_join, id}, socket) do
    maybe_start_child(id)
    :ok = Phoenix.PubSub.subscribe(Wiki.PubSub, id)
    editor = GenServer.call(via_tuple(id), :editor)

    socket =
      socket
      |> assign(:id, id)
      |> assign(:editor, editor)

    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      current_editor: id
    })

    push(socket, "clean", socket.assigns.editor.content)

    {:noreply, socket}
  end

  def handle_info({:updated, user_id}, socket) do
    if socket.assigns.user_id !== user_id do
      delta = GenServer.call(via_tuple(socket.assigns.id), {:diff, socket.assigns.editor})
      push(socket, "update", delta)
    end
    editor = GenServer.call(via_tuple(socket.assigns.id), :editor)
    {:noreply, assign(socket, :editor, editor)}
  end

  def via_tuple(id) do
    {:via, Registry, {EditorRegistry, id}}
  end

  defp maybe_start_child(id) do
    case Registry.lookup(EditorRegistry, id) do
      [{_pid, nil}] ->
        nil
      _ ->
        {:ok, _pid} = DynamicSupervisor.start_child(EditorSupervisor, {Editor, name: via_tuple(id)})
    end
  end

  def editor_hash(editor) do
    editor
    |> Map.get(:content)
    |> Map.from_struct()
    |> Jason.encode()
    |> (fn
      {:ok, content} -> :crypto.hash(:md5, content)
      {:error, _} -> nil
    end).()
    |> Base.encode16(case: :lower)
  end

  defp atomize_keys(ops) do
    AtomicMap.convert(ops, %{safe: false})
  end
end
