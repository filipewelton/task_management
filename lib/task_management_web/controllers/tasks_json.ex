defmodule TaskManagementWeb.TasksJSON do
  def render(_template, payload), do: Map.take(payload, [:task])
end
