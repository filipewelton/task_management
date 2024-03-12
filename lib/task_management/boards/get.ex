defmodule TaskManagement.Boards.Get do
  alias TaskManagement.{Board, Repo}

  def by_id(id) when is_bitstring(id) do
    case Repo.get(Board, id) do
      %Board{} = board -> preload(board)
      nil -> {:error, "Board not found!", 404}
    end
  end

  def by_id(id) when is_nil(id), do: {:error, "Board id is required!", 400}

  def by_id(_), do: {:error, "Board id should be a string!", 400}

  defp preload(board) do
    case Repo.preload(board, [:members]) do
      # coveralls-ignore-start
      nil -> {:error, "Unknown error.", 500}
      struct -> {:ok, struct}
    end
  end
end
