defmodule HomeBot.DataStore.InfluxConnection do
  use Instream.Connection, otp_app: :home_bot

  def get_single(query, database) do
    %{results: results} = query(query, database: database)

    %{series: [result]} = List.first(results)
    zipped = Enum.zip(result.columns, List.first(result.values))
    Enum.into(zipped, %{})
  end

  def get_list(query, database) do
    %{results: results} = query(query, database: database)

    %{series: [result]} = List.first(results)
    Enum.map(result.values, &(Enum.zip(result.columns, &1)))
    |> Enum.map(&(Enum.into(&1, %{})))
  end
end
