defmodule HellopodWeb.PageController do
  use HellopodWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
