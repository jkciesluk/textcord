defmodule Textcord.Repo do
  use Ecto.Repo,
    otp_app: :textcord,
    adapter: Ecto.Adapters.Postgres
end
