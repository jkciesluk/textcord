defmodule Textcord.ChannelsTest do
  use Textcord.DataCase

  alias Textcord.Channels

  describe "channels" do
    alias Textcord.Channels.Channel

    import Textcord.ChannelsFixtures

    @invalid_attrs %{name: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Channels.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Channels.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Channel{} = channel} = Channels.create_channel(valid_attrs)
      assert channel.name == "some name"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Channel{} = channel} = Channels.update_channel(channel, update_attrs)
      assert channel.name == "some updated name"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_channel(channel, @invalid_attrs)
      assert channel == Channels.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Channels.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Channels.change_channel(channel)
    end
  end

  describe "unreads" do
    alias Textcord.Channels.Unread

    import Textcord.ChannelsFixtures

    @invalid_attrs %{}

    test "list_unreads/0 returns all unreads" do
      unread = unread_fixture()
      assert Channels.list_unreads() == [unread]
    end

    test "get_unread!/1 returns the unread with given id" do
      unread = unread_fixture()
      assert Channels.get_unread!(unread.id) == unread
    end

    test "create_unread/1 with valid data creates a unread" do
      valid_attrs = %{}

      assert {:ok, %Unread{} = unread} = Channels.create_unread(valid_attrs)
    end

    test "create_unread/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_unread(@invalid_attrs)
    end

    test "update_unread/2 with valid data updates the unread" do
      unread = unread_fixture()
      update_attrs = %{}

      assert {:ok, %Unread{} = unread} = Channels.update_unread(unread, update_attrs)
    end

    test "update_unread/2 with invalid data returns error changeset" do
      unread = unread_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_unread(unread, @invalid_attrs)
      assert unread == Channels.get_unread!(unread.id)
    end

    test "delete_unread/1 deletes the unread" do
      unread = unread_fixture()
      assert {:ok, %Unread{}} = Channels.delete_unread(unread)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_unread!(unread.id) end
    end

    test "change_unread/1 returns a unread changeset" do
      unread = unread_fixture()
      assert %Ecto.Changeset{} = Channels.change_unread(unread)
    end
  end
end
