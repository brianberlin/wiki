defmodule Wiki.Editor do
  use GenServer, restart: :transient
  alias Wiki.Editor
  require Protocol

  Protocol.derive(Jason.Encoder, TextDelta, only: [:ops])

  @id_length 12

  defstruct id: nil, content: TextDelta.new()

  def create() do
    @id_length
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, @id_length)
  end

  def start_link(options) do
    [name: {:via, _, {_, id}}] = options
    GenServer.start_link(__MODULE__, %Editor{id: id}, options)
  end

  @impl true
  def init(editor) do
    {:ok, editor}
  end

  @impl true
  def handle_call(:editor, _from, editor) do
    {:reply, editor, editor}
  end

  @impl true
  def handle_call({:diff, old_editor}, _from, editor) do
    {:reply, diff(old_editor, editor), editor}
  end

  @impl true
  def handle_cast({:update, ops, user_id}, editor) do
    editor = update(editor, ops)
    {:noreply, editor, {:continue, {:updated, user_id}}}
  end

  @impl true
  def handle_cast(_, editor) do
    {:noreply, editor}
  end

  @impl true
  def handle_continue({:updated, user_id}, editor) do
    :ok = Phoenix.PubSub.broadcast(Wiki.PubSub, editor.id, {:updated, user_id})

    {:noreply, editor}
  end

  defp update(%{id: id, content: content}, ops) do
    case TextDelta.apply(content, %{ops: ops}) do
      {:ok, new_content} ->
        %{id: id, content: new_content}
      _error ->
        %{id: id, content: content}
    end
  end

  defp diff(%{content: %{ops: old_ops}}, %{content: %{ops: ops}}) do
    TextDelta.diff!(%{ops: old_ops}, %{ops: ops})
  end
end
