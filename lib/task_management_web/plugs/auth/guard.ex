defmodule TaskManagementWeb.Plugs.Auth.Guard do
  use Guardian, otp_app: :task_management

  alias TaskManagement.User
  alias TaskManagement.Users.Get, as: GetUser

  @impl true
  def subject_for_token(%User{id: id}, _claims), do: {:ok, id}

  @impl true
  def subject_for_token(_resource, _claims), do: {:error, "Invalid resource."}

  @impl true
  def build_claims(claims, _resource, _opts) do
    updated_claims =
      claims
      |> Map.put("exp", Guardian.timestamp() + 3600)
      |> Map.put("typ", "access")

    {:ok, updated_claims}
  end

  @impl true
  def resource_from_claims(claims) do
    response =
      claims
      |> Map.get("sub")
      |> GetUser.by_id()

    case response do
      {:ok, _user} = response -> response
      {:error, _, _} -> {:error, "Unauthenticated."}
    end
  end

  @impl true
  def after_encode_and_sign(_resource, claims, token, _options) do
    sub = Map.get(claims, "sub")
    Cachex.put(:guardian_tokens, token, sub)
    Cachex.expire(:guardian_tokens, token, :timer.hours(1))
    {:ok, token}
  end

  @impl true
  def on_verify(claims, token, _options) do
    case Cachex.get(:guardian_tokens, token) do
      {:ok, nil} -> {:error, "Unauthenticated."}
      {:ok, _} -> {:ok, claims}
    end
  end

  @impl true
  def on_revoke(claims, token, _options) do
    Cachex.del(:guardian_tokens, token)
    {:ok, claims}
  end
end
