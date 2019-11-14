defmodule Wiki.Editor do
  use GenServer, restart: :transient
  alias Wiki.Editor

  @id_length 12

  defstruct id: nil, lines: [], md5: nil

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
  def handle_cast({:update, line_number, content}, editor) do
    editor = Editor.update(editor, line_number - 1, content)
    {:noreply, editor, {:continue, :md5_check}}
  end

  @impl true
  def handle_continue(:md5_check, editor) do
    Phoenix.PubSub.broadcast(Wiki.PubSub, editor.id, :md5_check)
    {:noreply, editor}
  end

  def update(%{id: id, lines: lines}, line_number, content) do
    count = Enum.count(lines) - 1

    lines =
      cond do
        count < line_number ->
          List.insert_at(lines, line_number, content)

        true ->
          List.replace_at(lines, line_number, content)
      end

    %{id: id, lines: lines, md5: md5(lines)}
  end

  defp md5(lines) do
    :md5
    |> :crypto.hash(Enum.join(lines, "\n"))
    |> Base.encode16(case: :lower)
  end
end
