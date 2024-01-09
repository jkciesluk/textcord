defmodule Textcord.Servers.ServerUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "server_users" do

    belongs_to :user, Textcord.Accounts.User
    belongs_to :server, Textcord.Servers.Server


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server_user, attrs) do
    server_user
    |> cast(attrs, [:user_id, :server_id])
    |> validate_required([:user_id, :server_id])
  end
end
