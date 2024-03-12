defmodule TaskManagementWeb.BoardsControllerTest do
  use TaskManagementWeb.ConnCase

  import TaskManagement.Factory

  alias TaskManagement.Services.Notification.Recipient
  alias TaskManagementWeb.Plugs.Auth.Guard

  setup do
    user = insert(:user_struct)
    {:ok, token, _claims} = Guard.encode_and_sign(user)

    %{
      token: token,
      user: user
    }
  end

  describe "create" do
    test "when the board is created", %{
      conn: conn,
      token: token,
      user: user
    } do
      payload = %{
        "name" => Faker.Lorem.word(),
        "description" => Faker.Lorem.sentence(),
        "user_id" => user.id
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/boards", payload)
        |> json_response(201)

      assert Map.has_key?(response, "board")
    end
  end

  describe "delete" do
    setup %{user: owner_user} do
      master_user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: owner_user.id)
      master_member = insert(:member_struct, role: "master", user_id: master_user.id)
      board = insert(:board_struct, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            boards_id: [board.id], user_id: master_user.id, server_name: :delete_board
          },
          id: :delete_board
        )
      )

      %{board_id: board.id}
    end

    test "when the board is deleted", %{
      conn: conn,
      token: token,
      board_id: board_id
    } do
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete("/api/boards/#{board_id}")
      |> response(204)

      {:ok, notifications} = Recipient.get_notifications(:delete_board)

      assert length(notifications) == 1
      Recipient.stop(:delete_board)
      stop_supervised!(:delete_board)
    end
  end

  describe "get" do
    setup %{user: user} do
      member = insert(:member_struct, user_id: user.id)
      %{id: board_id} = insert(:board_struct, members: [member])

      %{board_id: board_id}
    end

    test "when the board is found", %{conn: conn, token: token, board_id: board_id} do
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get("/api/boards/#{board_id}")
        |> json_response(200)

      assert Map.has_key?(response, "board")
    end
  end

  describe "update" do
    setup %{user: owner_user} do
      master_user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: owner_user.id)
      master_member = insert(:member_struct, role: "master", user_id: master_user.id)
      board = insert(:board_struct, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            boards_id: [board.id], user_id: master_user.id, server_name: :update_board
          },
          id: :update_board
        )
      )

      %{board_id: board.id}
    end

    test "when the board is updated", %{
      conn: conn,
      token: token,
      board_id: board_id
    } do
      payload = %{
        "name" => Faker.Lorem.word(),
        "description" => Faker.Lorem.sentence()
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/boards/#{board_id}", payload)
        |> json_response(200)

      {:ok, notifications} = Recipient.get_notifications(:update_board)

      assert Map.has_key?(response, "board")
      assert length(notifications) == 1
      Recipient.stop(:update_board)
      stop_supervised!(:update_board)
    end
  end

  describe "add_member" do
    setup %{user: owner_user} do
      master_user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: owner_user.id)
      board = insert(:board_struct, members: [owner_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            boards_id: [board.id], user_id: master_user.id, server_name: :add_member
          },
          id: :add_member
        )
      )

      %{
        board_id: board.id,
        user_id: master_user.id
      }
    end

    test "when the member is added to the board", %{
      conn: conn,
      token: token,
      board_id: board_id,
      user_id: user_id
    } do
      payload = %{
        "board_id" => board_id,
        "user_id" => user_id,
        "role" => "master"
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/boards/members", payload)
        |> json_response(201)

      {:ok, notifications} = Recipient.get_notifications(:add_member)

      assert Map.has_key?(response, "board_id")
      assert Map.has_key?(response, "members")
      assert length(notifications) == 1
      Recipient.stop(:add_member)
      stop_supervised!(:add_member)
    end
  end

  describe "remove_member" do
    setup %{user: owner_user} do
      master_user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: owner_user.id)
      master_member = insert(:member_struct, role: "master", user_id: master_user.id)
      board = insert(:board_struct, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            boards_id: [board.id], user_id: master_user.id, server_name: :remove_member
          },
          id: :remove_member
        )
      )

      %{
        board_id: board.id,
        member_id: master_member.id
      }
    end

    test "when the member is removed from board", %{
      conn: conn,
      board_id: board_id,
      member_id: member_id,
      token: token
    } do
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete("/api/boards/members/#{board_id}/#{member_id}")
        |> json_response(204)

      {:ok, notifications} = Recipient.get_notifications(:remove_member)

      assert Map.has_key?(response, "board_id")
      assert Map.has_key?(response, "members")
      assert length(notifications) == 1
      Recipient.stop(:remove_member)
      stop_supervised!(:remove_member)
    end
  end

  describe "update_member" do
    setup %{user: owner_user} do
      master_user = insert(:user_struct)
      owner_member = insert(:member_struct, user_id: owner_user.id)
      master_member = insert(:member_struct, role: "master", user_id: master_user.id)
      board = insert(:board_struct, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            boards_id: [board.id], user_id: master_user.id, server_name: :update_member
          },
          id: :update_member
        )
      )

      %{
        board_id: board.id,
        member_id: master_member.id
      }
    end

    test "when the member role is updated", %{
      conn: conn,
      token: token,
      board_id: board_id,
      member_id: member_id
    } do
      payload = %{"role" => "team"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/boards/members/#{board_id}/#{member_id}", payload)
        |> json_response(200)

      {:ok, notifications} = Recipient.get_notifications(:update_member)

      assert Map.has_key?(response, "board_id")
      assert Map.has_key?(response, "member")
      assert length(notifications) == 1
      Recipient.stop(:update_member)
      stop_supervised!(:update_member)
    end
  end
end
