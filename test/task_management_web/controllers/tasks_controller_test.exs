defmodule TaskManagementWeb.TasksControllerTest do
  use TaskManagementWeb.ConnCase

  import TaskManagement.Factory

  alias TaskManagement.Services.Notification.Recipient
  alias TaskManagementWeb.Plugs.Auth.Guard

  setup do
    user = insert(:user_struct)
    {:ok, token, _claims} = Guard.encode_and_sign(user)
    member = insert(:member_struct, user_id: user.id)
    board = insert(:board_struct, members: [member])

    %{
      user: user,
      board: board,
      token: token
    }
  end

  describe "create" do
    test "when the task is created", %{conn: conn, board: board, token: token} do
      payload = build(:task, board_id: board.id)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/boards/tasks", payload)
        |> json_response(201)

      assert Map.has_key?(response, "task")
    end
  end

  describe "delete" do
    setup %{board: board, user: user} do
      owner_member = insert(:member_struct, user_id: user.id)
      master_member = insert(:member_struct)
      task = insert(:task_struct, board: board, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            [
              boards_id: [board.id],
              user_id: master_member.user_id,
              server_name: :delete_task
            ]
          },
          id: :delete_task
        )
      )

      %{task_id: task.id}
    end

    test "when the task is deleted", %{conn: conn, token: token, task_id: task_id} do
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete("/api/boards/tasks/#{task_id}")
      |> response(204)

      {:ok, notifications} = Recipient.get_notifications(:delete_task)

      assert length(notifications) == 1
      Recipient.stop(:delete_task)
      stop_supervised!(:delete_task)
    end
  end

  describe "get" do
    test "when the task is deleted", %{conn: conn, board: board, token: token} do
      task = insert(:task_struct, board: board)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get("/api/boards/tasks/#{task.id}")
        |> json_response(200)

      assert Map.has_key?(response, "task")
    end
  end

  describe "update" do
    setup %{board: board, user: user} do
      owner_member = insert(:member_struct, user_id: user.id)
      master_member = insert(:member_struct)
      task = insert(:task_struct, board: board, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            [
              boards_id: [board.id],
              user_id: master_member.user_id,
              server_name: :update_task
            ]
          },
          id: :update_task
        )
      )

      %{task_id: task.id}
    end

    test "when the task is updated", %{
      conn: conn,
      task_id: task_id,
      token: token
    } do
      payload = %{"status" => "done"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/boards/tasks/#{task_id}", payload)
        |> json_response(200)

      {:ok, notifications} = Recipient.get_notifications(:update_task)

      assert Map.has_key?(response, "task")
      assert length(notifications) == 1
      Recipient.stop(:update_task)
      stop_supervised!(:update_task)
    end
  end

  describe "add_member" do
    setup %{user: user} do
      owner_member = insert(:member_struct, user_id: user.id)
      master_member = insert(:member_struct)
      board = insert(:board_struct, members: [owner_member, master_member])
      task = insert(:task_struct, board: board, members: [owner_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            [
              boards_id: [board.id],
              user_id: master_member.user_id,
              server_name: :add_member
            ]
          },
          id: :add_member
        )
      )

      %{
        task_id: task.id,
        member_id: master_member.id
      }
    end

    test "when the task is updated", %{
      conn: conn,
      token: token,
      task_id: task_id,
      member_id: member_id
    } do
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/boards/tasks/add-member/#{task_id}/#{member_id}")
        |> json_response(200)

      {:ok, notifications} = Recipient.get_notifications(:add_member)

      assert Map.has_key?(response, "task")
      assert length(notifications) == 1
      Recipient.stop(:add_member)
      stop_supervised!(:add_member)
    end
  end

  describe "remove_member" do
    setup %{user: user} do
      owner_member = insert(:member_struct, user_id: user.id)
      master_member = insert(:member_struct)
      board = insert(:board_struct, members: [owner_member, master_member])
      task = insert(:task_struct, board: board, members: [owner_member, master_member])

      start_link_supervised!(
        Supervisor.child_spec(
          {
            Recipient,
            [
              boards_id: [board.id],
              user_id: master_member.user_id,
              server_name: :remove_member
            ]
          },
          id: :remove_member
        )
      )

      %{
        task_id: task.id,
        member_id: master_member.id
      }
    end

    test "when the task is updated", %{
      conn: conn,
      token: token,
      task_id: task_id,
      member_id: member_id
    } do
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/boards/tasks/remove-member/#{task_id}/#{member_id}")
        |> json_response(200)

      {:ok, notifications} = Recipient.get_notifications(:remove_member)

      assert Map.has_key?(response, "task")
      assert length(notifications) == 1
      Recipient.stop(:remove_member)
      stop_supervised!(:remove_member)
    end
  end
end
