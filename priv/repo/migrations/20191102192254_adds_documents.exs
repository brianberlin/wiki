defmodule Wiki.Repo.Migrations.AddsDocuments do
  use Ecto.Migration

  def change do
    create table "users" do
      add :first_name, :string
      add :last_name, :string
    end

    create table "documents" do
      add :title, :string
      add :document_id, references("documents")
      timestamps()
    end

    create table "lines" do
      add :line_number, :integer
      add :content, :string
      add :document_id, references("documents")
      add :user_id, references("users")
      timestamps()
    end
  end
end
