defmodule HomeBot.DataStore.InfluxConnection do
  use Instream.Connection, otp_app: :home_bot

  def get_single(query, database) do
    %{results: results} = query(query, database: database)

    get_first_result(results)
  end

  def get_list(query, database) do
    %{results: results} = query(query, database: database, timeout: 60_000)

    case List.first(results) do
      %{series: [result]} -> Enum.map(result.values, &(Enum.zip(result.columns, &1)))
                                  |> Enum.map(&(Enum.into(&1, %{})))
      _ -> []
    end
  end

  defp get_first_result(results) when is_list(results) do
    %{series: [result]} = List.first(results)
    zipped = Enum.zip(result.columns, List.first(result.values))
    Enum.into(zipped, %{})
  end

  defp get_first_result(_results), do: %{}
end
