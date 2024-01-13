defmodule Textcord.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias Textcord.Repo

  alias Textcord.Servers.Server

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers do
    Repo.all(Server)
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:servers)
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{data: %Server{}}

  """
  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  alias Textcord.Servers.ServerUser

  @doc """
  Returns the list of server_users.

  ## Examples

      iex> list_server_users()
      [%ServerUser{}, ...]

  """
  def list_server_users do
    Repo.all(ServerUser)
  end

  @doc """
  Gets a single server_user.

  Raises `Ecto.NoResultsError` if the Server user does not exist.

  ## Examples

      iex> get_server_user!(123)
      %ServerUser{}

      iex> get_server_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server_user!(id), do: Repo.get!(ServerUser, id)

  @doc """
  Creates a server_user.

  ## Examples

      iex> create_server_user(%{field: value})
      {:ok, %ServerUser{}}

      iex> create_server_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server_user(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:server_users)
    |> ServerUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a server_user.

  ## Examples

      iex> update_server_user(server_user, %{field: new_value})
      {:ok, %ServerUser{}}

      iex> update_server_user(server_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server_user(%ServerUser{} = server_user, attrs) do
    server_user
    |> ServerUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a server_user.

  ## Examples

      iex> delete_server_user(server_user)
      {:ok, %ServerUser{}}

      iex> delete_server_user(server_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server_user(%ServerUser{} = server_user) do
    Repo.delete(server_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server_user changes.

  ## Examples

      iex> change_server_user(server_user)
      %Ecto.Changeset{data: %ServerUser{}}

  """
  def change_server_user(%ServerUser{} = server_user, attrs \\ %{}) do
    ServerUser.changeset(server_user, attrs)
  end

  def get_server_by_name(name) do
    query = from s in Server,
      where: s.name == ^name,
      select: s

    Repo.one(query)
  end

  def get_available_servers(user) do
    query = from s in Server,
      join: su in ServerUser, on: s.id == su.server_id,
      where: su.user_id == ^user.id,
      select: s

    Repo.all(query)
  end

  def is_server_member?(user, server) do
    query = from su in ServerUser,
      where: su.user_id == ^user.id and su.server_id == ^server.id,
      select: su

    Repo.one(query) != nil
  end
end
