defmodule WikiWeb.EditorChannel do
  use WikiWeb, :channel

  def join("editor:" <> id, _, socket) do
    {:ok, assign(socket, :id, id)}
  end

  def handle_in("update", _params, socket) do
    {:noreply, socket}
  end

  def handle_in(_, _params, socket) do
    {:noreply, socket}
  end
end
