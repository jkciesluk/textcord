defmodule Textcord.Repo.Migrations.CreateServerUsers do
  use Ecto.Migration

  def change do
    create table(:server_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:server_users, [:user_id])
    create index(:server_users, [:server_id])
  end
end
