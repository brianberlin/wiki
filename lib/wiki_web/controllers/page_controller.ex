defmodule WikiWeb.PageController do
  use WikiWeb, :controller

  def index(conn, _params) do
    id = Wiki.Editor.create()
    redirect(conn, to: Routes.page_path(conn, :editor, [id]))
  end

  def editor(conn, %{"editor" => editor}) when is_list(editor) do
    render(conn, "editor.html", id: Enum.join(editor, "/"))
  end
end
