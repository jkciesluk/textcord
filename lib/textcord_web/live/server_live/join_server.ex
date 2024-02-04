defmodule TextcordWeb.ServerLive.JoinServer do
  use TextcordWeb, :live_component

  alias Textcord.Servers

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to join new servers</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="server-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form["name"] |> dbg()} name="name" type="text" value="" label="name" />

        <:actions>
          <.button phx-disable-with="Saving...">Join Server</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{name: name} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, %{"name" => name})}
  end

  # validate if  name is not empty
  def handle_event("validate", %{"name" => name}, socket) do
    if String.trim(name) == "" do
      {:noreply, assign(socket, :error, "Name cannot be empty")}
    else
      {:noreply, assign(socket, :error, nil)}
    end
  end

  # join server
  def handle_event("save", %{"name" => name}, socket) do
    if String.trim(name) == "" do
      {:noreply, socket |> put_flash(:error, "Server name cannot be empty")}
    else
      join_server(socket, Servers.get_server_by_name(name))
    end
  end

  defp join_server(socket, nil) do
    {:noreply,
     socket
     |> put_flash(:error, "Server not found")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp join_server(socket, server) do
    if Servers.is_server_member?(socket.assigns.current_user, server.id) do
      {:noreply,
       socket
       |> put_flash(:error, "Server already joined")
       |> push_patch(to: socket.assigns.patch)}
    else
      Servers.create_server_user(socket.assigns.current_user, %{"server_id" => server.id})
      notify_parent({:joined, server})
      {:noreply,
       socket
       |> put_flash(:info, "Server joined successfully")
       |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
