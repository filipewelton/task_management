defmodule TaskManagement.Users.Connect do
  require Logger

  alias TaskManagement.User
  alias TaskManagement.Users.Get

  @type payload :: %{
          email: String.t(),
          password: String.t()
        }

  @spec call(payload()) :: tuple()
  def call(payload) do
    email = Map.get(payload, :email)
    password = Map.get(payload, :password)

    with {:ok, user} <- Get.by_email(email),
         :ok <- validate_password(user, password) do
      {:ok, user}
    end
  end

  defp validate_password(%User{password: hash}, password) do
    case Bcrypt.verify_pass(password, hash) do
      true -> :ok
      false -> {:error, "Invalid password!", 401}
    end
  end
end
