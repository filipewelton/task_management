defmodule TaskManagementWeb.BoardsJSON do
  def render(template, payload)
      when template in ["create.json", "update.json", "show.json"] do
    Map.take(payload, [:board])
  end

  def render("update_member.json", payload), do: Map.take(payload, [:board_id, :member])

  def render(template, payload)
      when template in ["add_member.json", "remove_member.json"] do
    Map.get(payload, :response)
    |> Map.take([:board_id, :members])
  end
end
