defmodule Textcord.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:user_id])
    create index(:messages, [:channel_id])
  end
end
