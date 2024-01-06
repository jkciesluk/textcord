defmodule Textcord.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TextcordWeb.Telemetry,
      Textcord.Repo,
      {DNSCluster, query: Application.get_env(:textcord, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Textcord.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Textcord.Finch},
      # Start a worker by calling: Textcord.Worker.start_link(arg)
      # {Textcord.Worker, arg},
      # Start to serve requests, typically the last entry
      TextcordWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Textcord.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TextcordWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
