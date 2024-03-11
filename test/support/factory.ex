defmodule TaskManagement.Factory do
  use ExMachina.Ecto, repo: TaskManagement.Repo

  alias TaskManagement.{Board, Member, Task, User}

  def user_factory do
    %{
      email: Faker.Internet.email(),
      name: "John Doe",
      password: Faker.String.base64(12)
    }
  end

  def user_struct_factory do
    %User{
      email: Faker.Internet.email(),
      name: "John Doe",
      password: Faker.String.base64(12) |> Bcrypt.hash_pwd_salt()
    }
  end

  def board_struct_factory do
    member = insert(:member_struct)

    %Board{
      name: Faker.Lorem.word(),
      description: Faker.Lorem.sentence(),
      members: [member]
    }
  end

  def member_struct_factory do
    %User{id: user_id} = insert(:user_struct)

    %Member{
      role: "owner",
      user_id: user_id
    }
  end

  def task_struct_factory do
    %Member{} = member = insert(:member_struct)
    %Board{} = board = insert(:board_struct, members: [member])

    %Task{
      deadline: Date.add(Date.utc_today(), 1),
      checklist: [],
      description: Faker.Lorem.sentence(),
      labels: [],
      title: Faker.Lorem.sentence(),
      status: "todo",
      board: board,
      members: [member]
    }
  end

  def task_factory do
    %Member{} = member = insert(:member_struct)
    %Board{} = board = insert(:board_struct, members: [member])

    %{
      status: "todo",
      deadline: Date.add(Date.utc_today(), 1),
      checklist: [],
      description: Faker.Lorem.sentence(4..6),
      labels: [],
      title: Faker.Lorem.word(),
      board_id: board.id,
      member_id: member.id
    }
  end
end
