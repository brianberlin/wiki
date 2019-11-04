defmodule WikiWeb.PageController do
  use WikiWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.page_path(conn, :editor, Ecto.UUID.generate()))
  end

  def editor(conn, %{"id" => id}) do
    render(conn, "editor.html", id: id)
  end
end
