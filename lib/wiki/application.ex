defmodule Wiki.Application do
  use Application

  def start(_type, _args) do
    children = [
      WikiWeb.Endpoint,
      WikiWeb.Presence,
      {DynamicSupervisor, strategy: :one_for_one, name: Wiki.EditorSupervisor},
      {Registry, keys: :unique, name: Wiki.EditorRegistry},
    ]

    opts = [strategy: :one_for_one, name: Wiki.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WikiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
