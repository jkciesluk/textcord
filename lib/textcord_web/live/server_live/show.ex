defmodule TextcordWeb.ServerLive.Show do
  use TextcordWeb, :live_view

  alias Textcord.Servers
  alias Textcord.Channels.Channel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"server_id" => id}, _, socket) do
    server = Servers.get_server!(id) |> Textcord.Repo.preload([:user, :channels])
    is_admin = socket.assigns.current_user.id == server.user_id
    members = Servers.get_server_members(server.id)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:server, server)
     |> stream(:channels, server.channels)
     |> assign(:is_admin, is_admin)
     |> assign(:members, members)
     |> assign(:channel, %Channel{})}

  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
  defp page_title(:add_channel), do: "Add Channel"

end
