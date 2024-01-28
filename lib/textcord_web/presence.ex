defmodule TextcordWeb.Presence do
  use Phoenix.Presence,
    otp_app: :textcord,
    pubsub_server: Textcord.PubSub

end
