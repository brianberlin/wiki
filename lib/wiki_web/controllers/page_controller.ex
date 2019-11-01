defmodule WikiWeb.PageController do
  use WikiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
