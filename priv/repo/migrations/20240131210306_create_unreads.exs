defmodule Textcord.Repo.Migrations.CreateUnreads do
  use Ecto.Migration

  def change do
    create table(:unreads, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:unreads, [:channel_id])
    create index(:unreads, [:user_id])
  end
end
