defmodule Wiki.Lines do
  alias Wiki.{Repo, Document, Line}
  import Ecto.{Query}, warn: false
  use Ecto.Filters

  add_filter(:document_id, fn value, query ->
    where(query, [l], l.document_id == ^value)
  end)
  add_filter(:line_number, fn value, query ->
    where(query, [l], l.line_number == ^value)
  end)

  def insert_or_update_line(%Document{id: id}, %{"line_number" => line_number, "content" => content}) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:line, fn _, _ ->
      line = get_line(%{"q" => %{"document_id" => id, "line_number" => line_number}})
      {:ok, line || %Line{}}
    end)
    |> Ecto.Multi.insert_or_update(:update, fn %{line: line} ->
        Ecto.Changeset.change(line, content: content)
      end)
    |> Repo.transaction()
  end

  def get_line(params \\ %{}) do
    Line
    |> apply_filters(params)
    |> Repo.one()
  end
end
