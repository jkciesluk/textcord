defmodule Textcord.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :name, :string
    field :description, :string
    belongs_to :user, Textcord.Accounts.User
    has_many :server_users, Textcord.Servers.ServerUser
    has_many :channels, Textcord.Channels.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :description, :user_id])
    |> validate_required([:name, :description, :user_id])
  end
end
