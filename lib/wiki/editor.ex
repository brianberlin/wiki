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
  def handle_cast({:update, delta}, editor) do
    editor = Editor.update(editor, delta)
    {:noreply, editor, editor}
  end

  @impl true
  def handle_cast(_, editor) do
    {:noreply, editor}
  end

  def update(%{id: id, content: content}, delta) do
    case TextDelta.apply(content, delta) do
      {:ok, new_content} ->
        %{id: id, content: new_content}
      _ ->
        %{id: id, content: content}
    end
  end
end
