defmodule TextcordWeb.ChannelLive.ChannelFormComponent do
  use TextcordWeb, :live_component

  alias Textcord.Channels

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
        <.input field={@form[:name] |> dbg()} type="text" label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Server</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{channel: channel} = assigns, socket) do
    changeset = Channels.change_channel(channel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  # validate if  name is not empty
  def handle_event("validate", %{"channel" => channel_params}, socket) do
    changeset =
      socket.assigns.channel
      |> Channels.change_channel(channel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  # join server
  def handle_event("save", %{"channel" => channel_params}, socket) do
    case Channels.create_channel(socket.assigns.server, channel_params) do
      {:ok, channel} ->
        notify_parent({:created_channel, channel})

        {:noreply,
         socket
         |> put_flash(:info, "Created new channel")
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
