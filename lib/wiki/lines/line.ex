
defmodule Wiki.Line do
  use Ecto.Schema

  schema "lines" do
    field(:line_number, :integer)
    field(:content, :string)
    belongs_to(:document, Wiki.Document)
    timestamps()
  end
end
