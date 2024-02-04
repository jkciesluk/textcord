defmodule TextcordWeb.ChannelLive.ChatLiveComponent do
  alias Textcord.Channels
  alias Textcord.Messages
  require Logger
  use TextcordWeb, :live_component

  @impl true
  def mount(socket) do
    socket
    |> stream(:messages, [])
    |> assign(form: %{"text" => ""})
    |> assign(scroll_to_bottom: true)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{new_message: msg}, socket) do
    socket
    |> stream_insert(:messages, msg)
    |> then(&{:ok, &1})
  end

  def update(%{old_messages: msgs}, socket) do
    socket
    |> stream(:messages, msgs)
    |> then(&{:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("send-message", params, socket) do
    server_id = socket.assigns.server.id
    channel_id = socket.assigns.channel.id

    {:ok, message} = Messages.create_message(socket.assigns.current_user.id, channel_id, params)

    new_message = %{
      id: message.id,
      msg: message.text,
      user: socket.assigns.current_user.email,
      time:
        message.inserted_at
        |> Time.to_string()
        |> String.split(".")
        |> List.first()
    }

    TextcordWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", new_message)
    update_unread(server_id, channel_id, socket.assigns.current_user.id)

    {:noreply,
     socket
     |> assign(form: %{socket.assigns.form | "text" => ""})
     |> push_event("scroll-to-bottom", %{})}
  end

  def handle_event("update_text", %{"text" => text}, socket) do
    {:noreply, assign(socket, form: %{socket.assigns.form | "text" => text})}
  end

  def handle_event("scroll-to-bottom", _, socket) do
    {:noreply, socket |> push_patch(view: ChatLiveComponent)}
  end

  defp update_unread(server_id, channel_id, user_id) do
    Channels.on_message_send(server_id, channel_id, user_id)
    TextcordWeb.Endpoint.broadcast("server:" <> server_id, "unread", %{server_id: server_id, channel_id: channel_id})
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col h-screen w-full mx-auto mt-4" phx-hook="scroll-to-bottom">
      <div id="messages-container" class="border-2 flex-1 overflow-auto mb-4 p-4 max-h-[65vh] w-full">
        <ul class="list-group messages" phx-update="stream" id="messages-box">
          <%= for {_msg_id, msg} <- @streams.messages do %>
            <li class="mb-4 pb-4 border-b border-gray-300">
              <div class="font-bold mb-1"><%= msg.user %></div>
              <div><%= msg.msg %></div>
            </li>
          <% end %>
        </ul>
      </div>
      <div class="border border-2 p-4">
        <.form for={@form} phx-target={@myself} phx-submit="send-message">
          <div class="flex flex-row">
            <.input
              field={@form["text"]}
              type="text"
              name="text"
              value=""
              class="flex-1 p-2 mr-2 border border-2"
              placeholder="Enter text..."
              phx-value={@form["text"]}
              phx-change="update_text"
            />
            <.button class="bg-blue-500 text-white p-2">Send</.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
