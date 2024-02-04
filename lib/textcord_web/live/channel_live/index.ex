defmodule TextcordWeb.ChannelLive.Index do
  use TextcordWeb, :live_view
  alias Textcord.Channels
  alias Textcord.Servers
  require Logger

  alias TextcordWeb.{Endpoint, Presence}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"channel_id" => channel_id}, _, socket) do
    channel = Channels.get_channel!(channel_id)
    server = Servers.get_server!(channel.server_id)
    channels = Channels.get_server_channels(server.id)
    members = Servers.get_server_members(server.id) |> Enum.map(fn user -> user.email end)
    if connected?(socket), do: send(self(), {:fetch, channel_id})

    {:noreply,
     socket
     |> assign(:channel, channel)
     |> assign(:server, server)
     |> assign(:members, members)
     |> assign(:channels, channels)
     |> check_unread()
     |> subscribe_if_connected()
     |> init_presence()}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    send_update(TextcordWeb.ChannelLive.ChatLiveComponent,
      id: "chat-live",
      new_message: message
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    {:noreply,
     socket
     |> update_presence(payload)}
  end

  def handle_info(%{event: "created_channel", payload: channel}, socket) do
    {:noreply, socket |> assign(:channels, [channel | socket.assigns.channels])}
  end

  def handle_info({:fetch, channel_id}, socket) do
    channel = Channels.get_channel!(channel_id) |> Textcord.Repo.preload(:messages)
    messages = channel.messages |> Enum.map(fn msg -> Textcord.Repo.preload(msg, :user) end)

    formatted_messages =
      Enum.map(messages, fn message ->
        %{
          id: message.id,
          msg: message.text,
          user: message.user.email,
          time:
            message.inserted_at
            |> Time.to_string()
        }
      end)

    send_update(TextcordWeb.ChannelLive.ChatLiveComponent,
      id: "chat-live",
      old_messages: formatted_messages
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "unread", payload: %{channel_id: channel_id}}, socket) do
    if socket.assigns.channel.id == channel_id do
      Channels.mark_as_read(channel_id, socket.assigns.current_user.id)
      {:noreply, socket}
    else
      {:noreply, socket |> assign(:unreads, [channel_id | socket.assigns.unreads])}
    end
  end

  def handle_info(%{event: "edited_server", payload: server}, socket) do
    {:noreply, assign(socket, :server, server)}
  end

  defp check_unread(socket) do
    if connected?(socket) do
      Channels.mark_as_read(
        socket.assigns.channel.id,
        socket.assigns.current_user.id
      )

      unreads =
        Channels.get_server_unreads(
          socket.assigns.channels,
          socket.assigns.current_user.id
        )
        |> Enum.map(fn unread -> unread.channel_id end)

      assign(socket, unreads: unreads)
    else
      assign(socket, unreads: [])
    end
  end

  defp subscribe_if_connected(%{assigns: %{channel: channel, server: server}} = socket) do
    if connected?(socket) do
      Endpoint.unsubscribe("channel:#{channel.id}")
      Endpoint.unsubscribe("server:#{server.id}")
      Endpoint.subscribe("channel:#{channel.id}")
      Endpoint.subscribe("server:#{server.id}")
    end

    socket
  end

  defp init_presence(socket) do
    topic = "server:#{socket.assigns.server.id}"

    presence =
      if connected?(socket) do
        if !already_tracked?(socket, topic) do
          Presence.track(
            self(),
            topic,
            socket.assigns.current_user.email,
            %{}
          )
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

  defp update_presence(socket, %{joins: j, leaves: l}) do
    assign(socket,
      presence:
        Map.keys(j)
        |> MapSet.new()
        |> MapSet.union(socket.assigns.presence)
        |> MapSet.difference(MapSet.new(Map.keys(l)))
    )
  end
end
