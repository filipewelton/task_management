defmodule TaskManagementWeb.UsersControllerTest do
  use TaskManagementWeb.ConnCase

  import TaskManagement.Factory

  alias TaskManagement.Repo
  alias TaskManagementWeb.Plugs.Auth.Guard

  setup do
    user = insert(:user_struct)
    {:ok, token, _claims} = Guard.encode_and_sign(user)

    %{
      token: token,
      user_id: user.id
    }
  end

  describe "show" do
    test "when the user is unauthenticated", %{conn: conn} do
      conn
      |> get("/api/user")
      |> response(401)
    end

    test "when the user is authenticated", %{conn: conn, token: token} do
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> get("/api/user")
      |> response(200)
    end
  end

  describe "login" do
    setup do
      password = Faker.String.base64(12)
      hash = Bcrypt.hash_pwd_salt(password)
      user = insert(:user_struct, password: hash)

      %{
        email: user.email,
        password: password
      }
    end

    test "when the user is authenticated", %{
      conn: conn,
      email: email,
      password: password,
      token: token
    } do
      payload = %{
        "email" => email,
        "password" => password
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/user/login", payload)
        |> json_response(200)

      assert Map.has_key?(response, "token")
      assert Map.has_key?(response, "user")
    end

    test "when the email field is empty", %{conn: conn, token: token} do
      payload = %{
        "password" => Faker.String.base64(12)
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/api/user/login", payload)
        |> json_response(400)

      assert Map.get(response, "error") == "User email is required!"
    end

    test "when the password is invalid", %{conn: conn, email: email} do
      payload = %{
        "email" => email,
        "password" => Faker.String.base64(12)
      }

      response =
        conn
        |> post("/api/user/login", payload)
        |> json_response(401)

      assert Map.get(response, "error") == "Invalid password!"
    end

    test "when the user is not found", %{conn: conn, password: password} do
      payload = %{
        "email" => Faker.Internet.email(),
        "password" => password
      }

      response =
        conn
        |> post("/api/user/login", payload)
        |> json_response(404)

      assert Map.get(response, "error") == "User not found!"
    end
  end

  describe "logout" do
    test "when the user is logged out", %{conn: conn} do
      user = insert(:user_struct)
      {:ok, token, _claims} = Guard.encode_and_sign(user)

      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete("/api/user/logout")
      |> response(204)
    end

    test "when the user is not logged in", %{conn: conn} do
      user = insert(:user_struct)
      {:ok, token, _claims} = Guard.encode_and_sign(user)

      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete("/api/user/logout")
      |> response(204)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete("/api/user/logout")
        |> json_response(401)

      assert Map.get(response, "message") == "Unauthenticated."
    end
  end

  describe "create" do
    test "when the user is created", %{conn: conn} do
      payload = %{
        "name" => "John Doe",
        "email" => Faker.Internet.email(),
        "password" => Faker.String.base64(12)
      }

      response =
        conn
        |> post("/api/user", payload)
        |> json_response(201)

      assert Map.has_key?(response, "user")
    end

    test "when the email field is empty", %{conn: conn} do
      payload = %{
        "name" => "John Doe",
        "password" => Faker.String.base64(12)
      }

      response =
        conn
        |> post("/api/user", payload)
        |> json_response(400)

      assert Map.get(response, "error") == "Email can't be blank!"
    end

    test "when the email already registered", %{conn: conn} do
      email = Faker.Internet.email()

      insert(:user_struct, email: email)

      payload = %{
        "name" => "John Doe",
        "email" => email,
        "password" => Faker.String.base64(12)
      }

      response =
        conn
        |> post("/api/user", payload)
        |> json_response(409)

      assert Map.get(response, "error") == "This user already registered!"
    end
  end

  describe "delete" do
    test "when the user is deleted", %{conn: conn} do
      user = insert(:user_struct)
      {:ok, token, _claims} = Guard.encode_and_sign(user)

      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete("/api/user")
      |> response(204)
    end

    test "when the credential is invalid", %{conn: conn} do
      user = insert(:user_struct)
      {:ok, token, _claims} = Guard.encode_and_sign(user)

      Repo.delete(user)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete("/api/user")
        |> json_response(401)

      assert Map.get(response, "message", "Invalid credential!")
    end
  end

  describe "update" do
    test "when the user is updated", %{conn: conn, token: token} do
      payload = %{
        "password" => Faker.String.base64(24)
      }

      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> patch("/api/user", payload)
      |> response(200)
    end

    test "when the credential is invalid", %{conn: conn} do
      user = insert(:user_struct)
      {:ok, token, _claims} = Guard.encode_and_sign(user)

      Repo.delete(user)

      payload = %{
        "password" => Faker.String.base64(24)
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> patch("/api/user", payload)
        |> json_response(401)

      assert Map.get(response, "message", "Invalid credential!")
    end
  end
end
