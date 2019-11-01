defmodule WikiWeb.EditorChannel do
  use WikiWeb, :channel

  def join("editor:generic", _, socket) do
    {
      :ok,
      socket
      |> assign(:content, "<p>|")
      |> assign(:element, "p")
    }
  end

  def diff(old, new) do
    old
    |> String.myers_difference(new)
    |> Enum.map(fn
      {:eq, value} -> String.length(value)
      {key, value} -> [key, value]
    end)
  end

  def handle_in("key_down", params, %{assigns: %{content: content, element: element}} = socket) do
    [left, right] = String.split(content, "|")
    new_content = update_content(left, right, params, element)
    push(socket, "update", %{diff: diff(content, new_content)})

    socket =
      socket
      |> assign(:content, new_content)
      |> assign(:element, update_element(params, element))

    {:noreply, socket}
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
