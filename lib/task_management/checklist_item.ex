defmodule TaskManagement.ChecklistItem do
  @keys [:title, :checked]
  @enforce_keys @keys
  @derive {Jason.Encoder, only: @keys}

  defstruct @keys
end
