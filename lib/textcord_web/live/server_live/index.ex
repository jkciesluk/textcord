defmodule TextcordWeb.ServerLive.Index do
  alias TextcordWeb.Endpoint
  use TextcordWeb, :live_view

  alias Textcord.Channels
  alias Textcord.Servers
  alias Textcord.Servers.Server

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:servers, Servers.get_available_servers(socket.assigns.current_user))
     |> check_unread()
     |> subscribe_if_connected()
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"server_id" => id}) do
    socket
    |> assign(:page_title, "Edit Server")
    |> assign(:server, Servers.get_server!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Server")
    |> assign(:server, %Server{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Servers")
    |> assign(:server, nil)
  end

  defp apply_action(socket, :join, _params) do
    socket
    |> assign(:page_title, "Join Server")
    |> assign(:server, nil)
  end

  defp check_unread(socket) do
    if connected?(socket) do
      unreads =
        Channels.get_user_unread_servers(socket.assigns.current_user.id)

      assign(socket, unreads: unreads)
    else
      assign(socket, unreads: [])
    end
  end

  defp subscribe_if_connected(socket) do
    if connected?(socket) do
      Servers.get_available_servers(socket.assigns.current_user)
      |> Enum.each(& resubscribe(&1))
    end

    socket
  end

  defp resubscribe(server) do
    Endpoint.unsubscribe("server:#{server.id}")
    Endpoint.subscribe("server:#{server.id}")
  end

  @impl true
  def handle_info({TextcordWeb.ServerLive.FormComponent, {:saved, server}}, socket) do
    Endpoint.broadcast("server:#{server.id}", "edited_server", server)
    {:noreply, socket}
  end

  def handle_info({TextcordWeb.ServerLive.FormComponent, {:created, server}}, socket) do
    Endpoint.subscribe("server:#{server.id}")
    {:noreply, assign(socket, :servers, socket.assigns.servers ++ [server])}
  end

  def handle_info({TextcordWeb.ServerLive.JoinServer, {:joined, server}}, socket) do
    Endpoint.subscribe("server:#{server.id}")
    {:noreply, assign(socket, :servers, socket.assigns.servers ++ [server])}
  end

  def handle_info(%{event: "deleted_server", payload: server_id}, socket) do
    servers = socket.assigns.servers
    |> Enum.filter(& &1.id != server_id)
    {:noreply, assign(socket, :servers, servers)}
  end

  def handle_info(%{event: "edited_server", payload: server}, socket) do
    servers = socket.assigns.servers
    |> Enum.map(fn s -> if s.id == server.id, do: server, else: s end)
    {:noreply, assign(socket, :servers, servers)}
  end

  def handle_info(%{event: "unread", payload: %{server_id: server_id}}, socket) do
    {:noreply,
     socket |> assign(:unreads, [server_id | socket.assigns.unreads])}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"server_id" => id}, socket) do
    server = Servers.get_server!(id)
    Servers.delete_server(server)
    Endpoint.broadcast("server:#{id}", "deleted_server", id)
    {:noreply, socket}
  end
end
