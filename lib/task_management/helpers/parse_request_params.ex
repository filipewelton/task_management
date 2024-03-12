defmodule TaskManagement.Helpers.ParseRequestParams do
  @spec call(map()) :: map()
  def call(map) do
    map
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {key, value}, map ->
      Map.put(map, String.to_atom(key), value)
    end)
  end
end
