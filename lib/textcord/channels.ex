defmodule Textcord.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Textcord.Servers
  alias Textcord.Repo

  alias Textcord.Channels.Channel

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Repo.all(Channel)
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(server, attrs \\ %{}) do
    server
    |> Ecto.build_assoc(:channels)
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}) do
    Channel.changeset(channel, attrs)
  end

  def is_server_member?(user, channel_id) do
    channel = get_channel!(channel_id)
    Servers.is_server_member?(user, channel.server_id)
  end

  alias Textcord.Channels.Unread

  @doc """
  Returns the list of unreads.

  ## Examples

      iex> list_unreads()
      [%Unread{}, ...]

  """
  def list_unreads do
    Repo.all(Unread)
  end

  @doc """
  Gets a single unread.

  Raises `Ecto.NoResultsError` if the Unread does not exist.

  ## Examples

      iex> get_unread!(123)
      %Unread{}

      iex> get_unread!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unread!(id), do: Repo.get!(Unread, id)

  @doc """
  Creates a unread.

  ## Examples

      iex> create_unread(%{field: value})
      {:ok, %Unread{}}

      iex> create_unread(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_unread(attrs \\ %{}) do
    %Unread{}
    |> Unread.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a unread.

  ## Examples

      iex> update_unread(unread, %{field: new_value})
      {:ok, %Unread{}}

      iex> update_unread(unread, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unread(%Unread{} = unread, attrs) do
    unread
    |> Unread.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a unread.

  ## Examples

      iex> delete_unread(unread)
      {:ok, %Unread{}}

      iex> delete_unread(unread)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unread(%Unread{} = unread) do
    Repo.delete(unread)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unread changes.

  ## Examples

      iex> change_unread(unread)
      %Ecto.Changeset{data: %Unread{}}

  """
  def change_unread(%Unread{} = unread, attrs \\ %{}) do
    Unread.changeset(unread, attrs)
  end

  def on_message_send(server_id, channel_id, sender_id) do
    server_users = Servers.get_server_members(server_id) |> Enum.filter(fn user -> user.id != sender_id end)
    # insert to unread if not already there with this channel_id
    Enum.each(server_users, fn user ->
      unread = Repo.get_by(Unread, user_id: user.id, channel_id: channel_id)
      if unread == nil do
        create_unread(%{user_id: user.id, channel_id: channel_id})
      end
    end)

  end

  def mark_as_read(channel_id, user_id) do
    unread = Repo.get_by(Unread, user_id: user_id, channel_id: channel_id)
    if unread != nil do
      delete_unread(unread)
    end
  end

  def get_server_unreads(channels, user_id) do
    channels
    |> Enum.map(fn channel ->
      Repo.get_by(Unread, user_id: user_id, channel_id: channel.id)
    end)
    |> Enum.filter(fn unread -> unread != nil end)
  end

  def get_user_unread_servers(user_id) do
    query = from(u in Unread, where: u.user_id == ^user_id)

    Repo.all(query)
    |> Enum.map(fn unread -> Repo.get!(Channel, unread.channel_id).server_id end)
    |> Enum.uniq()
  end
end
