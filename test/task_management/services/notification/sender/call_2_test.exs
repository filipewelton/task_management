defmodule TaskManagement.Services.Notification.Sender.Call2Test do
  use ExUnit.Case

  alias TaskManagement.Services.Notification.{Recipient, Sender}

  @board_id "24022c47-3a4a-41b4-a06f-dfffb7592bbf"
  @user_id_1 "4abd55ba-4b97-41f7-924b-27d9b2959400"
  @user_id_2 "d70b3957-cf15-4373-8c5c-9afd8af38de9"

  setup do
    start_supervised!(
      Supervisor.child_spec(
        {
          Recipient,
          boards_id: [@board_id], user_id: @user_id_1, server_name: :server_1
        },
        id: :server_1
      )
    )

    start_supervised!(
      Supervisor.child_spec(
        {
          Recipient,
          boards_id: [@board_id], user_id: @user_id_2, server_name: :server_2
        },
        id: :server_2
      )
    )

    :ok
  end

  test "when the message is sent to all members" do
    payload = ~s({
      "sender_id": "#{Faker.UUID.v4()}",
      "message": "#{Faker.Lorem.sentence()}",
      "date": "#{DateTime.utc_now()}"
    })

    :ok = Sender.call(@board_id, payload)
    :timer.sleep(50)
    {:ok, list_1} = Recipient.get_notifications(:server_1)
    {:ok, list_2} = Recipient.get_notifications(:server_2)

    assert length(list_1) == 1 and length(list_2)
  end
end
