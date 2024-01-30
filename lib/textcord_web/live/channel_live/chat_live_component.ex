defmodule TextcordWeb.ChannelLive.ChatLiveComponent do
  alias Textcord.Messages
  require Logger
  use TextcordWeb, :live_component

  @impl true
  def mount(socket) do
    # IO.inspect("mount")
    socket
    |> stream(:messages, [])
    |> assign(form: %{"text" => nil})
    |> then(& {:ok, &1})
  end

  @impl true
  def update(%{new_message: msg}, socket) do
    IO.inspect("update with message #{inspect(msg)}")

    socket
     |> stream_insert(:messages, msg)
     |> then(& {:ok, &1})
  end



  def update(%{old_messages: msgs}, socket) do

    socket
     |> stream(:messages, msgs)
     |> then(& {:ok, &1})
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> then(& {:ok, &1})
  end

  @impl true
  def handle_event("send-message", %{"text" => message} = params, socket) do
    Logger.info(send_message: message)
    server_id = socket.assigns.server.id
    channel_id = socket.assigns.channel.id

    {:ok, message} = Messages.create_message(socket.assigns.current_user.id, channel_id, params)
    new_message = %{id: message.id,
                    msg: message.text,
                    user: socket.assigns.current_user.email,
                    time: message.inserted_at
                          |> Time.to_string()
                          |> String.split(".")
                          |> List.first()
                  }
    TextcordWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", new_message)
    TextcordWeb.Endpoint.broadcast("server:" <> server_id, "unread", channel_id)

    {:noreply, socket |> assign(form: %{})}
  end


  @impl true
  def render(assigns) do
    ~H"""
      <div id={@id} class="h-[400px] flex flex-col justify-items-end">
        <div id="messages-container border-2 h-[350px] overflow-auto"
             class="ml-4" >
          <ul class="list-group messages" phx-update="stream" id="messages-box">
              <%= for {_msg_id, msg} <-  @streams.messages do %>
                  <li>
                    <div><%= msg.user %></div>
                    <span><%= msg.msg %></span>
                  </li>
              <% end %>
          </ul>
        </div>
        <div class="ml-4 border  border-2 mb-0 ">

          <.form for={@form} phx-target={@myself} phx-submit="send-message">

            <div class="flex flex-row w-[350px]">
                <.input field={@form["text"]}
                        type="text"
                        name="text"
                        value=""
                        class="h-full"
                        placeholder="Enter text..." />
              <.button>Send</.button>
            </div>
          </.form>
       </div>
      </div>
    """
  end
end
