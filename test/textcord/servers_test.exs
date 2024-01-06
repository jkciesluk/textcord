defmodule Textcord.ServersTest do
  use Textcord.DataCase

  alias Textcord.Servers

  describe "servers" do
    alias Textcord.Servers.Server

    import Textcord.ServersFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_servers/0 returns all servers" do
      server = server_fixture()
      assert Servers.list_servers() == [server]
    end

    test "get_server!/1 returns the server with given id" do
      server = server_fixture()
      assert Servers.get_server!(server.id) == server
    end

    test "create_server/1 with valid data creates a server" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Server{} = server} = Servers.create_server(valid_attrs)
      assert server.name == "some name"
      assert server.description == "some description"
    end

    test "create_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(@invalid_attrs)
    end

    test "update_server/2 with valid data updates the server" do
      server = server_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Server{} = server} = Servers.update_server(server, update_attrs)
      assert server.name == "some updated name"
      assert server.description == "some updated description"
    end

    test "update_server/2 with invalid data returns error changeset" do
      server = server_fixture()
      assert {:error, %Ecto.Changeset{}} = Servers.update_server(server, @invalid_attrs)
      assert server == Servers.get_server!(server.id)
    end

    test "delete_server/1 deletes the server" do
      server = server_fixture()
      assert {:ok, %Server{}} = Servers.delete_server(server)
      assert_raise Ecto.NoResultsError, fn -> Servers.get_server!(server.id) end
    end

    test "change_server/1 returns a server changeset" do
      server = server_fixture()
      assert %Ecto.Changeset{} = Servers.change_server(server)
    end
  end

  describe "server_users" do
    alias Textcord.Servers.ServerUser

    import Textcord.ServersFixtures

    @invalid_attrs %{}

    test "list_server_users/0 returns all server_users" do
      server_user = server_user_fixture()
      assert Servers.list_server_users() == [server_user]
    end

    test "get_server_user!/1 returns the server_user with given id" do
      server_user = server_user_fixture()
      assert Servers.get_server_user!(server_user.id) == server_user
    end

    test "create_server_user/1 with valid data creates a server_user" do
      valid_attrs = %{}

      assert {:ok, %ServerUser{} = server_user} = Servers.create_server_user(valid_attrs)
    end

    test "create_server_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server_user(@invalid_attrs)
    end

    test "update_server_user/2 with valid data updates the server_user" do
      server_user = server_user_fixture()
      update_attrs = %{}

      assert {:ok, %ServerUser{} = server_user} = Servers.update_server_user(server_user, update_attrs)
    end

    test "update_server_user/2 with invalid data returns error changeset" do
      server_user = server_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Servers.update_server_user(server_user, @invalid_attrs)
      assert server_user == Servers.get_server_user!(server_user.id)
    end

    test "delete_server_user/1 deletes the server_user" do
      server_user = server_user_fixture()
      assert {:ok, %ServerUser{}} = Servers.delete_server_user(server_user)
      assert_raise Ecto.NoResultsError, fn -> Servers.get_server_user!(server_user.id) end
    end

    test "change_server_user/1 returns a server_user changeset" do
      server_user = server_user_fixture()
      assert %Ecto.Changeset{} = Servers.change_server_user(server_user)
    end
  end
end
