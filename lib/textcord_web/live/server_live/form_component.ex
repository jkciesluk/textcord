defmodule TextcordWeb.ServerLive.FormComponent do
  use TextcordWeb, :live_component

  alias Textcord.Channels
  alias Textcord.Servers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage server records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="server-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Server</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{server: server} = assigns, socket) do
    changeset = Servers.change_server(server)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      socket.assigns.server
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"server" => %{"name" => name, "description" => description}}, socket) do
    if String.trim(name) == "" do
      # Server name is empty, prevent creation
      {:noreply, socket |> put_flash(:error, "Server name cannot be empty")}
    else
      save_server(socket, socket.assigns.action, %{"name" => name, "description" => description})
    end
  end

  defp save_server(socket, :edit, server_params) do
    case Servers.update_server(socket.assigns.server, server_params) do
      {:ok, server} ->
        notify_parent({:saved, server})

        {:noreply,
         socket
         |> put_flash(:info, "Server updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_server(socket, :new, server_params) do
    case Servers.create_server(socket.assigns.current_user, server_params) do
      {:ok, server} ->
        # Insert admin to server_users
        Servers.create_server_user(socket.assigns.current_user, %{"server_id" => server.id})
        Channels.create_channel(server, %{"name" => "general"})
        notify_parent({:created, server})

        {:noreply,
         socket
         |> put_flash(:info, "Server created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
