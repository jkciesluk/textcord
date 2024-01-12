defmodule TextcordWeb.PageController do
  use TextcordWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/servers")
  end
end
