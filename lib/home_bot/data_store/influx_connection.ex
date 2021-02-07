defmodule HomeBot.DataStore.InfluxConnection do
  use Instream.Connection, otp_app: :home_bot

  def get_query(query, database) do
    %{results: results} = query(query, database: database)

    %{series: [result]} = List.first(results)
    zipped = Enum.zip(result.columns, List.first(result.values))
    Enum.into(zipped, %{})
  end
end
