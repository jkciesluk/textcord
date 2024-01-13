defmodule TextcordWeb.ServerLive.Index do
  use TextcordWeb, :live_view

  alias Textcord.Servers
  alias Textcord.Servers.Server

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :servers, Servers.get_available_servers(socket.assigns.current_user) |> IO.inspect())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
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

  @impl true
  def handle_info({TextcordWeb.ServerLive.FormComponent, {:saved, server}}, socket) do
    {:noreply, stream_insert(socket, :servers, server)}
  end

  @impl true
  def handle_info({TextcordWeb.ServerLive.JoinServer, {:joined, server}}, socket) do
    {:noreply, stream_insert(socket, :servers, server)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    {:ok, _} = Servers.delete_server(server)

    {:noreply, stream_delete(socket, :servers, server)}
  end
end
