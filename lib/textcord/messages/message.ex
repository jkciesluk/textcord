defmodule Textcord.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    belongs_to :user, Textcord.Accounts.User
    belongs_to :channel, Textcord.Channels.Channel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :user_id, :channel_id])
    |> validate_required([:text, :user_id, :channel_id])
  end
end
