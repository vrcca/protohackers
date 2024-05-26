defmodule Protohackers.SmokeTest do
  @moduledoc """
  # 0: Smoke Test

  Deep inside Initrode Global's enterprise management framework lies a component
  that writes data to a server and expects to read the same data back. (Think of
  it as a kind of distributed system delay-line memory). We need you to write the
  server to echo the data back.

  Accept TCP connections.

  Whenever you receive data from a client, send it back unmodified.

  Make sure you don't mangle binary data, and that you can handle at least 5
  simultaneous clients.

  Once the client has finished sending data to you it shuts down its sending
  side. Once you've reached end-of-file on your receiving side, and sent back
  all the data you've received, close the socket so that the client knows
  you've finished. (This point trips up a lot of proxy software, such as ngrok;
  if you're using a proxy and you can't work out why you're failing the check,
  try hosting your server in the cloud instead).

  Your program will implement the TCP Echo Service from [RFC 862](https://www.rfc-editor.org/rfc/rfc862.html).
  """

  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    accept_loop(socket)
  end

  defp accept_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Protohackers.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    accept_loop(socket)
  end

  defp serve(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        reply(client, data)
        serve(client)
    end
  end

  defp reply(socket, data) do
    :gen_tcp.send(socket, data)
  end
end
