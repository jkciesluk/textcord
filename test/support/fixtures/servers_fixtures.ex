defmodule Textcord.ServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Textcord.Servers` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    {:ok, server} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Textcord.Servers.create_server()

    server
  end

  @doc """
  Generate a server_user.
  """
  def server_user_fixture(attrs \\ %{}) do
    {:ok, server_user} =
      attrs
      |> Enum.into(%{

      })
      |> Textcord.Servers.create_server_user()

    server_user
  end
end
