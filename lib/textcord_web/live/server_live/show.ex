defmodule TextcordWeb.ServerLive.Show do
  use TextcordWeb, :live_view

  alias Textcord.Channels
  alias Textcord.Servers
  alias Textcord.Channels.Channel

  alias TextcordWeb.{Endpoint, Presence}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"server_id" => id}, _, socket) do
    server = Servers.get_server!(id) |> Textcord.Repo.preload([:user, :channels])
    is_admin = socket.assigns.current_user.id == server.user_id
    members = Servers.get_server_members(server.id) |> Enum.map(fn user -> user.email end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:server, server)
     |> check_unread()
     |> assign(:is_admin, is_admin)
     |> assign(:members, members)
     |> assign(:topic, "server:#{server.id}")
     |> init_presence()
     |> subscribe_if_connected()
     |> assign(:channel, %Channel{})}
  end

  defp init_presence(socket) do
    topic = socket.assigns.topic

    presence =
      if connected?(socket) do
        if !already_tracked?(socket, topic) do
          Presence.track(self(), topic, socket.assigns.current_user.email, %{})
        end

        Presence.list(topic) |> Map.keys() |> MapSet.new()
      else
        MapSet.new()
      end

    assign(socket, presence: presence)
  end

  defp already_tracked?(socket, topic) do
    Presence.list(topic)
    |> Map.keys()
    |> MapSet.new()
    |> MapSet.member?(socket.assigns.current_user.email)
  end

  defp check_unread(socket) do
    if (connected?(socket)) do
      unreads =
        Channels.get_server_unreads(socket.assigns.server.channels, socket.assigns.current_user.id)
        |> Enum.map(fn unread -> unread.channel_id end)

      assign(socket, unreads: unreads)
    else
      assign(socket, unreads: [])
    end
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    {:noreply,
     socket
     |> update_presence(payload)}
  end

  def handle_info(%{event: "unread", payload: channel_id}, socket) do
    IO.inspect("unread server #{channel_id} for user #{socket.assigns.current_user.email}")

    {:noreply,
     socket |> assign(:unreads, [channel_id | socket.assigns.unreads])}
  end

  defp update_presence(socket, %{joins: j, leaves: l}) do
    assign(socket,
      presence:
        Map.keys(j)
        |> MapSet.new()
        |> MapSet.union(socket.assigns.presence)
        |> MapSet.difference(MapSet.new(Map.keys(l)))
    )
  end



  defp subscribe_if_connected(%{assigns: %{topic: topic}} = socket) do
    if connected?(socket) do
      Endpoint.subscribe(topic)
      assign(socket, chat_state: :subscribed)
    else
      assign(socket, chat_state: :unsubscribed)
    end
  end

  defp page_title(:show), do: "Show Server"
  defp page_title(:edit), do: "Edit Server"
  defp page_title(:add_channel), do: "Add Channel"
end
