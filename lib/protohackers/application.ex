defmodule Protohackers.Application do
  use Application

  def start(_type, _args) do
    smoke_test_port = String.to_integer(System.get_env("SMOKE_TEST_PORT") || "4040")

    children = [
      {Task.Supervisor, name: Protohackers.TaskSupervisor},
      {Task, fn -> Protohackers.SmokeTest.accept(smoke_test_port) end}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
