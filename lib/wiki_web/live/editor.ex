defmodule WikiWeb.EditorLive do
  use Phoenix.LiveView
  import Phoenix.HTML, only: [raw: 1]
  def render(assigns) do
    ~L"""
    <div phx-keydown="key_down" phx-target="window"><%= raw(@content) %></div>
    """
  end

  def mount(_session, socket) do
    {
      :ok,
      assign(
        socket,
        content: "<p>|",
        element: "p"
      )
    }
  end

  def handle_event("key_down", params, socket) do
    {:noreply, response(socket, params)}
  end

  def response(%{assigns: %{content: content, element: element}} = socket, params) do
    IO.inspect(params)
    [left, right] = String.split(content, "|")
    content = update_content(left, right, params, element)
    element = update_element(params, element)
    assign(socket, content: content, element: element)
  end

  defp update_content(left, right, %{"altKey" => altKey, "code" => "Backspace"}, _) do
    left =
      if altKey do
        left
        |> String.split(" ")
        |> List.pop_at(-1)
        |> elem(1)
        |> Enum.join(" ")
      else
        String.slice(left, 0, String.length(left) - 1)
      end

    left <> "|" <> right
  end

  defp update_content(left, right, %{"code" => "Space"}, _) do
    left <> " |" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "1"}, element) do
    left <> "</" <> element <> "><h1>|" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "2"}, element) do
    left <> "</" <> element <> "><h2>|" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "3"}, element) do
    left <> "</" <> element <> "><h3>|" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "4"}, element) do
    left <> "</" <> element <> "><h4>|" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "5"}, element) do
    left <> "</" <> element <> "><h5>|" <> right
  end

  defp update_content(left, right, %{"metaKey" => true, "key" => "p"}, element) do
    left <> "</" <> element <> "><p>|" <> right
  end

  defp update_content(left, right, %{
    "altKey" => false,
    "ctrlKey" => false,
    "metaKey" => false,
    "key" => <<key::binary-size(1)>>
  }, _) do
    left <> key <> "|" <> right
  end

  defp update_content(left, right, _, _), do: left <> "|" <> right


  def update_element(%{"metaKey" => true, "key" => "1"}, _), do: "h1"
  def update_element(%{"metaKey" => true, "key" => "2"}, _), do: "h2"
  def update_element(%{"metaKey" => true, "key" => "3"}, _), do: "h3"
  def update_element(%{"metaKey" => true, "key" => "4"}, _), do: "h4"
  def update_element(%{"metaKey" => true, "key" => "5"}, _), do: "h5"
  def update_element(%{"metaKey" => true, "key" => "p"}, _), do: "p"
  def update_element(_, element), do: element
end
