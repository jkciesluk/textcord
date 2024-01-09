defmodule Textcord.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "channels" do
    field :name, :string
    belongs_to :server, Textcord.Servers.Server
    has_many :messages, Textcord.Messages.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :server_id])
    |> validate_required([:name, :server_id])
  end
end
