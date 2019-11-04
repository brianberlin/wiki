defmodule Wiki.Document do
  use Ecto.Schema

  alias Wiki.Document
  import Ecto.Changeset

  schema "documents" do
    field(:title, :string)
    timestamps()
  end

  def changeset(%Document{} = document, attrs) do
    cast(document, attrs, [:title])
  end
end
