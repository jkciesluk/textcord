defmodule TextcordWeb.ServerLive.Show do
  use TextcordWeb, :live_view

  alias Textcord.Servers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    server = Servers.get_server!(id) |> Textcord.Repo.preload(:channels)
    is_admin = socket.assigns.current_user.id == server.user_id

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:server, server)
     |> assign(:is_admin, is_admin)}
  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
end
