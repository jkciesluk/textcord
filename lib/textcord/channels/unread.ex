defmodule Textcord.Channels.Unread do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "unreads" do

    belongs_to :user, Textcord.Accounts.User
    belongs_to :channel, Textcord.Channels.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(unread, attrs) do
    unread
    |> cast(attrs, [:user_id, :channel_id])
    |> validate_required([:user_id, :channel_id])
  end
end
