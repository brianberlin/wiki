defmodule WikiWeb.EditorChannelTest do
  use WikiWeb.ChannelCase

  defp create_socket() do
    WikiWeb.UserSocket
    |> socket(UUID.uuid4(), %{user_id: UUID.uuid4()})
    |> subscribe_and_join(WikiWeb.EditorChannel, "editor:test")
    |> elem(2)
  end

  setup do
    {:ok, socket: create_socket()}
  end

  describe "things" do
    test "ping replies with status ok", %{socket: socket} do
      delta = %{"ops" => [%{"insert" => "a"}]}
      _ref = push(socket, "update", delta)
      assert_push(:update, delta)
    end
  end

  # test "shout broadcasts to editor:lobby", %{socket: socket} do
  #   push socket, "shout", %{"hello" => "all"}
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from! socket, "broadcast", %{"some" => "data"}
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
