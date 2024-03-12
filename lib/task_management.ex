defmodule TaskManagement do
  alias TaskManagement.Helpers.ParseRequestParams
  alias TaskManagement.Boards.AddMember, as: AddMemberToBoard
  alias TaskManagement.Boards.Create, as: CreateBoard
  alias TaskManagement.Boards.Delete, as: DeleteBoard
  alias TaskManagement.Boards.Get, as: GetBoard
  alias TaskManagement.Boards.RemoveMember, as: RemoveMemberFromBoard
  alias TaskManagement.Boards.Update, as: UpdateBoard
  alias TaskManagement.Members.Update, as: UpdateMember
  alias TaskManagement.Tasks.AddMember, as: AddMemberToTask
  alias TaskManagement.Tasks.Create, as: CreateTask
  alias TaskManagement.Tasks.Delete, as: DeleteTask
  alias TaskManagement.Tasks.Get, as: GetTask
  alias TaskManagement.Tasks.RemoveMember, as: RemoveMemberFromTask
  alias TaskManagement.Tasks.Update, as: UpdateTask
  alias TaskManagement.Users.Connect
  alias TaskManagement.Users.Create, as: CreateUser
  alias TaskManagement.Users.Delete, as: DeleteUser
  alias TaskManagement.Users.Disconnect
  alias TaskManagement.Users.Update, as: UpdateUser

  defdelegate parse_request_params(map), to: ParseRequestParams, as: :call

  defdelegate create_board(payload), to: CreateBoard, as: :call

  defdelegate delete_board(board_id, executor), to: DeleteBoard, as: :call

  defdelegate get_board_by_id(id), to: GetBoard, as: :by_id

  defdelegate update_board(payload, owner), to: UpdateBoard, as: :call

  defdelegate add_member_to_board(payload, owner), to: AddMemberToBoard, as: :call

  defdelegate remove_member_from_board(payload, executor),
    to: RemoveMemberFromBoard,
    as: :call

  defdelegate update_member_from_board(payload, executor), to: UpdateMember, as: :call

  defdelegate connect(payload), to: Connect, as: :call

  defdelegate create_user(payload), to: CreateUser, as: :call

  defdelegate delete_user(id), to: DeleteUser, as: :call

  defdelegate disconnect(token), to: Disconnect, as: :call

  defdelegate update_user(user, payload), to: UpdateUser, as: :call

  defdelegate add_member_to_task(payload, executor), to: AddMemberToTask, as: :call

  defdelegate create_task(payload, executor), to: CreateTask, as: :call

  defdelegate delete_task(id, executor), to: DeleteTask, as: :call

  defdelegate get_task_by_id(id, executor \\ nil), to: GetTask, as: :by_id

  defdelegate remove_member_from_task(payload, executor),
    to: RemoveMemberFromTask,
    as: :call

  defdelegate update_task(payload, executor), to: UpdateTask, as: :call
end
