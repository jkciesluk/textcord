defmodule Textcord.Servers.ServerUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "server_users" do

    field :user_id, :binary_id
    field :server_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(server_user, attrs) do
    server_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
