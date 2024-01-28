defmodule TextcordWeb.ChannelLive.Index do
  use TextcordWeb, :live_view
  alias Textcord.Channels
  alias Textcord.Servers
  require Logger

  alias TextcordWeb.{Endpoint, Presence}

  @topic "channel:"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"channel_id" => channel_id}, _, socket) do
    channel = Channels.get_channel!(channel_id)
    topic = @topic <> to_string(channel_id)
    server = Servers.get_server!(channel.server_id)
    if connected?(socket), do: send(self(), {:fetch, channel_id})
    {:noreply,
     socket
     |> assign(:channel, channel)
     |> assign(:topic, topic)
     |> assign(:server, server)
     |> subscribe_if_connected()
     |> init_presence()
    }
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(handle_info: message)

    send_update(TextcordWeb.ChannelLive.ChatLiveComponent,
      id: "chat-live",
      new_message: message
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: payload}, socket) do
    send_update(TextcordWeb.ChannelLive.ChatLiveComponent,
      id: "chat-live",
      presence_diff: payload
    )

    {:noreply,
     socket
     |> update_presence(payload)}
  end

  def handle_info({:fetch, channel_id}, socket) do
    Logger.info(handle_info: "fetching messages")
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
            |> String.split(".")
            |> List.first()
        }
      end)

    send_update(TextcordWeb.ChannelLive.ChatLiveComponent,
      id: "chat-live",
      old_messages: formatted_messages
    )

    {:noreply, socket}
  end

  defp subscribe_if_connected(%{assigns: %{topic: topic}} = socket) do
    if connected?(socket) do
      Endpoint.subscribe(topic)

      assign(socket, chat_state: :subscribed)
    else
      assign(socket, chat_state: :unsubscribed)
    end
  end

  defp init_presence(%{assigns: %{topic: topic}} = socket) do
    presence =
      if connected?(socket) do
        {:ok, _} =
          Presence.track(self(), topic, socket.assigns.current_user.email, %{})

        Presence.list(topic) |> Map.keys() |> MapSet.new() #|> IO.inspect()
      else
        MapSet.new()
      end

    assign(socket, presence: presence)
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
